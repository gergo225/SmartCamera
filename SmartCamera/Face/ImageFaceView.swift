//
//  ImageFaceView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 08.07.2025.
//

import SwiftUI
import PhotosUI

struct ImageFaceView: View {
    @State private var viewModel = ImageFaceViewModel()

    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        if let photo = viewModel.photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .overlay {
                    ForEach(viewModel.faces, id: \.landmarkObservation.uuid) { face in
                        let faceRect = face.normalizedRect
                        BoundingBox(normalizedRect: faceRect)
                            .stroke(.orange, lineWidth: 1)

                        let landmarkObservation = face.landmarkObservation
                        if let faceContour = landmarkObservation.landmarks?.faceContour {
                            FaceLandmark(region: faceContour)
                                .stroke(.blue, lineWidth: 2)
                        }

                        if let leftEye = landmarkObservation.landmarks?.leftEye {
                            FaceLandmark(region: leftEye)
                                .stroke(.green, lineWidth: 2)
                        }

                        if let rightEye = landmarkObservation.landmarks?.rightEye {
                            FaceLandmark(region: rightEye)
                                .stroke(.green, lineWidth: 2)
                        }
                    }
                }
        } else {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Select a Photo")
            }
            .onChange(of: selectedPhoto) { _, newPhoto in
                guard let newPhoto else { return }
                viewModel.analyzeFace(photo: newPhoto)
            }
        }
    }
}
