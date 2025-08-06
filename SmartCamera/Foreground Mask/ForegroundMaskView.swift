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
                imageView(originalImage: photo)
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
        .safeAreaInset(edge: .bottom) {
            Picker("Effect", selection: $viewModel.selectedFilterType) {
                ForEach(ImageFilterType.allCases) { filterType in
                    Text(filterType.filter.title)
                        .tag(filterType)
                }
            }
            .onChange(of: viewModel.selectedFilterType) { _, newValue in
                guard let selectedImage else { return }
                viewModel.analyzeImage(photo: selectedImage)
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

    func imageView(originalImage: UIImage) -> some View {
        let uiImage = shouldShowMask ? viewModel.modifiedImage : originalImage

        return Image(uiImage: uiImage ?? originalImage)
            .resizable()
            .scaledToFit()
    }
}
