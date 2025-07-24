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
    var selectedFilter: ImageFilter = .blur

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
                guard let self else { return }
                foregroundMask = maskImage
                applyFilterToBackground(imageFilter: selectedFilter)
            }
        }
    }

    func applyFilterToBackground(imageFilter: ImageFilter) {
        guard let foregroundMask,
              let cgImage = photo?.cgImage else {
            return
        }
        let ciImage = CIImage(cgImage: cgImage)

        let filter: CIFilter = {
            switch imageFilter {
            case .blur:
                let blur = CIFilter.gaussianBlur()
                blur.inputImage = ciImage
                blur.radius = 20
                return blur
            case .sepia:
                let darken = CIFilter.sepiaTone()
                darken.inputImage = ciImage
                return darken
            case .pixel:
                let pixel = CIFilter.pixellate()
                pixel.inputImage = ciImage
                pixel.center = CGPoint(x: 150, y: 150)
                pixel.scale = 10
                return pixel
            case .comic:
                let comic = CIFilter.comicEffect()
                comic.inputImage = ciImage
                return comic
            case .edges:
                let edges = CIFilter.edgeWork()
                edges.inputImage = ciImage
                edges.radius = 5
                return edges
            case .crystalize:
                let crystalize = CIFilter.crystallize()
                crystalize.inputImage = ciImage
                crystalize.radius = 30
                return crystalize
            }
        }()

        guard let modifiedBackground = filter.outputImage else {
            return
        }

        let blendFilter = CIFilter.blendWithMask()
        blendFilter.backgroundImage = modifiedBackground
        blendFilter.inputImage = ciImage
        blendFilter.maskImage = foregroundMask

        guard let imageWithModifiedBackground = blendFilter.outputImage,
              let resultImage = ciContext.createCGImage(imageWithModifiedBackground, from: imageWithModifiedBackground.extent) else {
            return
        }

        modifiedImage = UIImage(cgImage: resultImage)
    }
}
