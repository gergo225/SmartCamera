//
//  ForegroundAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 05.07.2025.
//

import SwiftUI

struct ForegroundMaskView: View {
    let imageUrl: URL

    @State private var viewModel = ForegroundMaskViewModel()
    @State private var image: UIImage? = nil

    var body: some View {
        VStack {
            if let image {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()

                    if let maskImage = viewModel.maskImage {
                        Image(uiImage: maskImage)
                            .resizable()
                            .scaledToFit()
                            .blendMode(.multiply)
                            .opacity(0.6)
                    }
                }
            } else {
                Text("Loading image...")
            }
        }
        .padding()
        .task {
            image = UIImage(contentsOfFile: imageUrl.path())

            if image == nil {
                print("Failed to load image at: \(imageUrl.absoluteURL)")
            }

            viewModel.analyzeImage(url: imageUrl)
        }
    }
}
