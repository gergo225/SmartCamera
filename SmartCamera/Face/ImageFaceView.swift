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

    @State private var selectedImage: PhotosPickerItem?

    var body: some View {
        VStack {
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
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
            }
        }
        .toolbar {
            if selectedImage != nil {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Change Image")
                }
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            viewModel.analyzeFace(photo: newImage)
        }
    }
}
