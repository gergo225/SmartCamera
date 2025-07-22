//
//  VideoView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUI
import AVFoundation
import Accelerate
import Combine

enum CameraType {
    case back
    case front

    var isMirrored: Bool {
        switch self {
        case .back:
            false
        case .front:
            true
        }
    }

    mutating func toggle() {
        switch self {
        case .back:
            self = .front
        case .front:
            self = .back
        }
    }
}

struct VideoView: UIViewControllerRepresentable {
    let onFrameCaptured: (CVPixelBuffer) -> Void
    @Binding var cameraType: CameraType
    @Binding var videoFrameSize: CGSize
    @Binding var videoFrameOffset: CGPoint

    let cameraSource: CameraSource
    private let preview = PreviewView()

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()

        cameraSource.prepareForStreaming()
        cameraSource.connect(to: preview)

        preview.previewLayer.frame = viewController.view.bounds
        preview.previewLayer.videoGravity = .resizeAspect
        viewController.view.layer.addSublayer(preview.layer)

        context.coordinator.previewLayer = preview.previewLayer
        context.coordinator.startCapturingFrames()

        cameraSource.startStreaming()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        cameraSource.switchCamera(to: cameraType)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: VideoView
        var previewLayer: AVCaptureVideoPreviewLayer?

        init(_ parent: VideoView) {
            self.parent = parent
        }

        func startCapturingFrames() {
            Task { [weak self] in
                guard let self else { return }
                for await capturedFrame in await parent.cameraSource.frameStream {
                    onFrameCaptured(capturedFrame)
                }
            }
        }

        func onFrameCaptured(_ pixelBuffer: CVPixelBuffer) {
            if let previewLayer, self.parent.videoFrameSize == .zero {
                let previewFrame = previewLayer.frame

                let imageSize = calculateImageSize(pixelBuffer: pixelBuffer, in: previewLayer.frame)
                let imageOffset = calculateImageOffset(imageSize: imageSize, in: previewFrame)

                DispatchQueue.main.async { [weak self] in
                    self?.parent.videoFrameSize = imageSize
                    self?.parent.videoFrameOffset = imageOffset
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.parent.onFrameCaptured(pixelBuffer)
            }
        }

        private func calculateImageSize(pixelBuffer: CVPixelBuffer, in frame: CGRect) -> CGSize {
            let fullImageWidth = CVPixelBufferGetWidth(pixelBuffer)
            let fullImageHeight = CVPixelBufferGetHeight(pixelBuffer)

            let widthRatio = CGFloat(fullImageWidth) / frame.width
            let heightRatio = CGFloat(fullImageHeight) / frame.height

            // ScaleAspectFit
            let scaleDownRatio = max(widthRatio, heightRatio)

            let imageWidth = CGFloat(fullImageWidth) / scaleDownRatio
            let imageHeight = CGFloat(fullImageHeight) / scaleDownRatio

            return CGSize(width: imageWidth, height: imageHeight)
        }

        private func calculateImageOffset(imageSize: CGSize, in frame: CGRect) -> CGPoint {
            let xOffset = (frame.width - imageSize.width) / 2
            let yOffset = frame.minY + (frame.height - imageSize.height) / 2

            return CGPoint(x: xOffset, y: yOffset)
        }

        private func mirrorPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let width = CVPixelBufferGetWidth(pixelBuffer)

            let transform = CGAffineTransform(scaleX: -1, y: 1)
                .translatedBy(x: -CGFloat(width), y: 0)
            let mirroredImage = ciImage.transformed(by: transform)

            let context = CIContext()
            var mirroredBuffer: CVPixelBuffer?
            CVPixelBufferCreate(nil, width, CVPixelBufferGetHeight(pixelBuffer), CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &mirroredBuffer)

            guard let mirrored = mirroredBuffer else { return nil }
            context.render(mirroredImage, to: mirrored)
            return mirrored
        }
    }
}
