//
//  VideoView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUI
import AVFoundation
import Accelerate

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
}

struct VideoView: UIViewControllerRepresentable {
    let onFrameCaptured: (CVPixelBuffer) -> Void
    var cameraType: CameraType = .front
    @Binding var videoFrameSize: CGSize
    @Binding var videoFrameOffset: CGPoint

    let captureSession = AVCaptureSession()

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()

        guard let videoCaptureDevice = getVideoCaptureDevice(),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return viewController
        }

        captureSession.addInput(videoInput)

        let videoOutput = AVCaptureVideoDataOutput()

        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspect
        viewController.view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer

        // Set output rotation to match rotation seen in preview, otherwise output is rotated by default to landscape
        if let videoOutputConnection = videoOutput.connection(with: .video) {
            videoOutputConnection.videoRotationAngle = previewLayer.connection!.videoRotationAngle
        }

        Task(priority: .background) {
            captureSession.startRunning()
        }

        return viewController
    }

    private func getVideoCaptureDevice() -> AVCaptureDevice? {
        switch cameraType {
        case .back:
            AVCaptureDevice.default(for: .video)
        case .front:
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: VideoView
        var previewLayer: AVCaptureVideoPreviewLayer?

        init(_ parent: VideoView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            if let previewLayer, self.parent.videoFrameSize == .zero {
                let previewFrame = previewLayer.frame

                let imageSize = calculateImageSize(pixelBuffer: pixelBuffer, in: previewLayer.frame)
                let imageOffset = calculateImageOffset(imageSize: imageSize, in: previewFrame)

                DispatchQueue.main.async {
                    self.parent.videoFrameSize = imageSize
                    self.parent.videoFrameOffset = imageOffset
                }
            }

            if parent.cameraType.isMirrored {
                if let mirroredPixelBuffer = mirrorPixelBuffer(pixelBuffer) {
                    parent.onFrameCaptured(mirroredPixelBuffer)
                }
            } else {
                parent.onFrameCaptured(pixelBuffer)
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
