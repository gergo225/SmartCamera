//
//  AestheticsViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 15.10.2025.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI

@Observable
final class AestheticsViewModel {
    var score: Double?
    var selectedImage: UIImage?

    private let visionManager = VisionManager.shared

    func analyzeImage(photo: PhotosPickerItem) {
        Task { [weak self] in
            guard let self,
            let imageData = try? await photo.loadTransferable(type: Data.self) else { return }

            await MainActor.run { [weak self] in
                self?.selectedImage = UIImage(data: imageData)
            }

            guard let aestheticsScore = await visionManager.getAestheticsScore(data: imageData) else { return }

            await MainActor.run { [weak self] in
                self?.score = aestheticsScore
            }
        }
    }
}
