//
//  VideoView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUI
import AVFoundation

struct VideoView: UIViewControllerRepresentable {
    let onFrameCaptured: (CVPixelBuffer) -> Void
    @Binding var videoFrameSize: CGSize

    let captureSession = AVCaptureSession()

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
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
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayerSize = previewLayer.frame.size

        // Set output rotation to match rotation seen in preview, otherwise output is rotated by default to landscape
        if let videoOutputConnection = videoOutput.connection(with: .video) {
            videoOutputConnection.videoRotationAngle = previewLayer.connection!.videoRotationAngle
        }

        Task(priority: .background) {
            captureSession.startRunning()
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: VideoView
        var previewLayerSize: CGSize = .zero

        init(_ parent: VideoView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            // TODO: bug: width still doesn't match preview layer
            if self.parent.videoFrameSize == .zero, previewLayerSize != .zero {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.parent.videoFrameSize = self.previewLayerSize
                }
            }

//            let width = CVPixelBufferGetWidth(pixelBuffer) //
//            let height = CVPixelBufferGetHeight(pixelBuffer)  // 2
//            DispatchQueue.main.async {
//                self.parent.videoFrameSize = CGSize(width: width, height: height)
//            }

            parent.onFrameCaptured(pixelBuffer)
        }
    }
}
