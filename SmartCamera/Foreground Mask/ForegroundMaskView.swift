//
//  ForegroundAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 05.07.2025.
//

import SwiftUI
import PhotosUI

struct ForegroundMaskView: View {
    @State private var viewModel = ForegroundMaskViewModel()
    @State private var shouldShowMask = true
    @State private var selectedImage: PhotosPickerItem?

    var body: some View {
        VStack {
            if let photo = viewModel.photo {
                ZStack {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()

                    if let maskImage = viewModel.maskImage, shouldShowMask {
                        Image(uiImage: maskImage)
                            .resizable()
                            .scaledToFit()
                            .blendMode(.multiply)
                            .opacity(0.6)
                    }
                }
                .onLongPressGesture(
                    minimumDuration: 0,
                    perform: {
                        shouldShowMask = false
                    },
                    onPressingChanged: { inProgress in
                        if !inProgress {
                            shouldShowMask = true
                        }
                    }
                )
            } else {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
            }
        }
        .padding()
        .toolbar {
            if selectedImage != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Change Image")
                    }
                }
            }

        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            viewModel.analyzeImage(photo: newImage)
        }
    }
}
