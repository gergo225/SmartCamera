//
//  AestheticsView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 15.10.2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct AestheticsView: View {
    @State private var viewModel = AestheticsViewModel()
    @State private var selectedImage: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if let selectedImage = viewModel.selectedImage, let score = viewModel.score {
                ZStack(alignment: .center) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()

                    VStack {
                        Spacer()
                        Text("Score: \(score)")
                    }
                }
            } else {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            viewModel.analyzeImage(photo: newImage)
        }
    }
}

#Preview {
    AestheticsView()
}
