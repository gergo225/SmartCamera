//
//  ImageAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 28.06.2025.
//

import Foundation

@Observable
class ImageContourViewModel {
    var contourPoints: [CGPoint] = []
    var isAnalyzing: Bool = false

    private let visionManager = VisionManager.shared

    func analyzeImage(url: URL, showDetails: Bool = false) {
        isAnalyzing = true
        Task { [weak self] in
            guard let self else { return }

            let contours = await visionManager.detectImageContours(url: url, showNestedContours: showDetails)

            DispatchQueue.main.async { [weak self] in
                self?.contourPoints = contours
                self?.isAnalyzing = false
            }
        }
    }
}
