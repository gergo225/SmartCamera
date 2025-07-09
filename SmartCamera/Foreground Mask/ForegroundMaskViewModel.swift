//
//  ForegroundAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 05.07.2025.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI

@Observable
class ForegroundMaskViewModel {
    var photo: UIImage?
    var maskImage: UIImage?

    private let visionManager = VisionManager.shared

    func analyzeImage(photo: PhotosPickerItem) {
        Task { [weak self] in
            guard let self else { return }

            guard let imageData = try? await photo.loadTransferable(type: Data.self) else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.photo = UIImage(data: imageData)
            }

            guard let maskImage = await visionManager.detectImageForegroundMask(data: imageData) else {
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
