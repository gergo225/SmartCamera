//
//  VideoAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import Foundation
import AVFoundation

@Observable
final class VideoAnalyzerViewModel {
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        print("Processing frame...")
        // TODO: detect contours
    }
}
