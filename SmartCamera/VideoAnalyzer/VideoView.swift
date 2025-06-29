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

        init(_ parent: VideoView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            parent.onFrameCaptured(pixelBuffer)
        }
    }
}
