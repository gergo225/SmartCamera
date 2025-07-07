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
    @State private var shouldShowMask = true

    var body: some View {
        VStack {
            if let image {
                ZStack {
                    Image(uiImage: image)
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
