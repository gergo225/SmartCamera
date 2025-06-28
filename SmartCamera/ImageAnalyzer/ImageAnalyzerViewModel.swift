//
//  ImageAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 28.06.2025.
//

import Foundation

@Observable
class ImageAnalyzerViewModel {
    private let visionManager = VisionManager.shared

    var contourPoints: [CGPoint] = []

    func analyzeImage(url: URL) {
        Task { [weak self] in
            guard let self else { return }

            let contours = await visionManager.detectImageContours(url: url)

            DispatchQueue.main.async { [weak self] in
                self?.contourPoints = contours
            }
        }
    }
}
