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
    let landmarkObservation: FaceObservation
}

@Observable
class ImageFaceViewModel {
    var faces: [FaceItem] = []
    var photo: UIImage?

    private let visionManager = VisionManager.shared

    func analyzeFace(photo: PhotosPickerItem) {
        print("Analyzing face data...")
        
        Task { [weak self] in
            guard let self else { return }

            guard let imageData = try? await photo.loadTransferable(type: Data.self) else {
                return
            }

            let faceResults = await visionManager.detectFaces(data: imageData)

            DispatchQueue.main.async { [weak self] in
                self?.photo = UIImage(data: imageData)
                self?.faces = faceResults
            }
        }
    }
}
