//
//  CameraSource.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 22.07.2025.
//

import AVFoundation

protocol CameraSource {
    var frameStream: AsyncStream<CVPixelBuffer> { get }

    func prepareForStreaming()
    func startStreaming()
    func connect(to: PreviewView)
    func switchCamera(to: CameraType)
}
