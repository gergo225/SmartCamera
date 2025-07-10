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

    @State private var shouldShowFaceBox = true
    @State private var shouldShowFaceContour = true
    @State private var shouldShowEyes = true
    @State private var shouldShowMouth = true
    @State private var shouldShowNose = true

    var body: some View {
        VStack {
            if let photo = viewModel.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        ForEach(viewModel.faces, id: \.landmarkObservation.uuid) { face in
                            if shouldShowFaceBox {
                                let faceRect = face.normalizedRect
                                BoundingBox(normalizedRect: faceRect)
                                    .stroke(.orange, lineWidth: 1)
                            }

                            let landmarkObservation = face.landmarkObservation

                            if shouldShowFaceContour, let faceContour = landmarkObservation.landmarks?.faceContour {
                                    FaceLandmark(region: faceContour)
                                        .stroke(.blue, lineWidth: 2)
                            }

                            if shouldShowEyes {
                                if let leftEye = landmarkObservation.landmarks?.leftEye {
                                    FaceLandmark(region: leftEye)
                                        .stroke(.green, lineWidth: 2)
                                }

                                if let rightEye = landmarkObservation.landmarks?.rightEye {
                                    FaceLandmark(region: rightEye)
                                        .stroke(.green, lineWidth: 2)
                                }
                            }

                            if shouldShowMouth, let mouth = landmarkObservation.landmarks?.outerLips {
                                FaceLandmark(region: mouth)
                                    .stroke(.blue, lineWidth: 2)
                            }

                            if shouldShowNose, let nose = landmarkObservation.landmarks?.nose {
                                FaceLandmark(region: nose)
                                    .stroke(.blue, lineWidth: 2)
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

            Menu {
                Toggle("Face Box", isOn: $shouldShowFaceBox)
                Toggle("Face", isOn: $shouldShowFaceContour)
                Toggle("Eyes", isOn: $shouldShowEyes)
                Toggle("Mouth", isOn: $shouldShowMouth)
                Toggle("Nose", isOn: $shouldShowNose)
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            viewModel.analyzeFace(photo: newImage)
        }
    }
}
