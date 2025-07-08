//
//  ImageFaceViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 08.07.2025.
//

import Foundation
import Vision
import _PhotosUI_SwiftUI

struct FaceItem {
    let normalizedRect: NormalizedRect
}

@Observable
class ImageFaceViewModel {
    var face: FaceItem?
    var photo: UIImage?

    private let visionManager = VisionManager.shared

    func analyzeFace(photo: PhotosPickerItem) {
        print("Analyzing face data...")
        
        Task { [weak self] in
            guard let self else { return }

            guard let imageData = try? await photo.loadTransferable(type: Data.self) else {
                return
            }

            guard let faceResult = await visionManager.detectFace(data: imageData) else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.photo = UIImage(data: imageData)
                self?.face = faceResult
            }
        }
    }
}
