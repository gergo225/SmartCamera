//
//  ForegroundAnalyzerViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 05.07.2025.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

@Observable
class ForegroundMaskViewModel {
    var photo: UIImage?
    var modifiedImage: UIImage?

    private let visionManager = VisionManager.shared
    private var foregroundMask: CIImage?
    private let ciContext = CIContext()

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

            DispatchQueue.main.async { [weak self] in
                self?.foregroundMask = maskImage
                self?.applyBlurToBackground()
            }
        }
    }


    func applyBlurToBackground() {
        guard let foregroundMask,
              let cgImage = photo?.cgImage else {
            return
        }
        let ciImage = CIImage(cgImage: cgImage)

        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImage
        filter.radius = 20

        guard let blurredBackground = filter.outputImage else {
            return
        }

        let blendFilter = CIFilter.blendWithMask()
        blendFilter.backgroundImage = blurredBackground
        blendFilter.inputImage = ciImage
        blendFilter.maskImage = foregroundMask

        guard let imageWithModifiedBackground = blendFilter.outputImage,
              let resultImage = ciContext.createCGImage(imageWithModifiedBackground, from: imageWithModifiedBackground.extent) else {
            return
        }

        modifiedImage = UIImage(cgImage: resultImage)
    }
}
