//
//  ForegroundAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 05.07.2025.
//

import Foundation
import UIKit

@Observable
class ForegroundMaskViewModel {
    var maskImage: UIImage?

    private let visionManager = VisionManager.shared

    func analyzeImage(url: URL) {
        Task { [weak self] in
            guard let self else { return }

            guard let maskImage = await visionManager.detectImageForegroundMask(url: url) else {
                return
            }

            let ciContext = CIContext()
            guard let cgImage = ciContext.createCGImage(maskImage, from: maskImage.extent) else {
                return
            }
            let uiImage = UIImage(cgImage: cgImage)

            DispatchQueue.main.async { [weak self] in
                self?.maskImage = uiImage
            }
        }
    }
}
