//
//  ImageAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 28.06.2025.
//

import Foundation
import _PhotosUI_SwiftUI

@Observable
class ImageContourViewModel {
    var photo: UIImage?
    var contourPoints: [CGPoint] = []
    var isAnalyzing: Bool = false

    private let visionManager = VisionManager.shared

    func analyzeImage(photo: PhotosPickerItem, showDetails: Bool = false) {
        isAnalyzing = true
        Task { [weak self] in
            guard let self else { return }

            guard let imageData = try? await photo.loadTransferable(type: Data.self) else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.photo = UIImage(data: imageData)
            }

            let contours = await visionManager.detectImageContours(data: imageData, showNestedContours: showDetails)

            DispatchQueue.main.async { [weak self] in
                self?.contourPoints = contours
                self?.isAnalyzing = false
            }
        }
    }
}
