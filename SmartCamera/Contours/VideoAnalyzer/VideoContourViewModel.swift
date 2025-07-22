//
//  VideoAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import Foundation
import AVFoundation

@Observable
final class VideoContourViewModel {
    var contourPoints: [CGPoint] = []
    var isProcessing: Bool = false

    private let visionManager = VisionManager.shared

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        guard !isProcessing else {
            return
        }

        isProcessing = true
        Task { [weak self] in
            guard let self else { return }

            // TODO: make nested countours a switch
            let coutourNormalizedPoints = await visionManager.detectImageContours(pixelBuffer: pixelBuffer, showNestedContours: true)
            DispatchQueue.main.async { [weak self] in
                self?.contourPoints = coutourNormalizedPoints
                self?.isProcessing = false
            }
        }
    }
}
