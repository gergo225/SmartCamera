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
                    if let faceRect = viewModel.face?.normalizedRect {
                        BoundingBox(normalizedRect: faceRect)
                            .stroke(.orange, lineWidth: 2)
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
