//
//  CameraManager.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 22.07.2025.
//

import AVFoundation
import CoreImage

class CameraManager: NSObject, CameraSource {
    lazy var frameStream: AsyncStream<CVPixelBuffer> = {
        AsyncStream { continuation in
            onFrameCaptured = { pixelBuffer in
                continuation.yield(pixelBuffer)
            }
        }
    }()

    private var onFrameCaptured: ((CVPixelBuffer) -> Void)?

    private var captureSession = AVCaptureSession()
    private let videoQueue = DispatchQueue(label: "videoQueue")
    private var previewView: PreviewView?
    private var cameraType: CameraType = .back

    func startStreaming() {
        videoQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func connect(to preview: PreviewView) {
        self.previewView = preview
        previewView?.setSession(captureSession)

        configureOutputRotationFromPreview()
    }

    func switchCamera(to camera: CameraType) {
        guard camera != cameraType else { return }
        cameraType = camera

        configureSession()
    }

    func prepareForStreaming() {
        configureSession()
    }

    private func configureSession() {
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }

        removeAllInputsAndOutputs()

        addInput()
        addOutput()

        configureOutputRotationFromPreview()
    }

    private func removeAllInputsAndOutputs() {
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
    }

    private func addInput() {
        guard let videoCaptureDevice = getVideoCaptureDevice(),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput),
              !captureSession.inputs.contains(videoInput) else {
            return
        }

        captureSession.addInput(videoInput)
    }

    private func addOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoOutput),
              !captureSession.outputs.contains(videoOutput) else {
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        captureSession.addOutput(videoOutput)
    }

    private func getVideoCaptureDevice() -> AVCaptureDevice? {
        switch cameraType {
        case .back:
            AVCaptureDevice.default(for: .video)
        case .front:
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }
    }

    private func configureOutputRotationFromPreview() {
        // Set output rotation to match rotation seen in preview, otherwise output is rotated by default to landscape
        guard let videoOutputConnection = captureSession.outputs.first?.connection(with: .video),
              let previewLayerConnection = previewView?.previewLayer.connection else {
            return
        }
        videoOutputConnection.videoRotationAngle = previewLayerConnection.videoRotationAngle
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if cameraType.isMirrored {
            if let mirroredPixelBuffer = mirrorPixelBuffer(pixelBuffer) {
                onFrameCaptured?(mirroredPixelBuffer)
            }
        } else {
            onFrameCaptured?(pixelBuffer)
        }
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
