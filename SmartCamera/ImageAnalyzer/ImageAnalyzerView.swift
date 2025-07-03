//
//  ImageAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 28.06.2025.
//

import SwiftUI
import Vision

struct ImageAnalyzerView: View {
    let imageUrl: URL

    @State private var viewModel = ImageAnalyzerViewModel()
    @State private var image: UIImage? = nil
    @State private var shouldShowDetailedContours = false

    var body: some View {
        VStack {
            if let image {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            Canvas { context, size in
                                let normalizedPoints = viewModel.contourPoints
                                DrawingUtils.drawNormalizedPointsOnCanvas(context: context, size: size, points: normalizedPoints)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                }
            } else {
                Text("Loading image...")
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Toggle(isOn: $shouldShowDetailedContours) {
                    Text("Detailed Contours")
                }
                .disabled(viewModel.isAnalyzing)
            }
        }
        .onChange(of: shouldShowDetailedContours) { _, newValue in
            viewModel.analyzeImage(url: imageUrl, showDetails: newValue)
        }
        .task {
            image = UIImage(contentsOfFile: imageUrl.path())

            if image == nil {
                print("Failed to load image at: \(imageUrl.absoluteURL)")
            }

            viewModel.analyzeImage(url: imageUrl)
        }
    }
}

extension CGPoint {
    func fromNormalizedToRegular(width: Int, height: Int) -> CGPoint {
        return VNImagePointForNormalizedPoint(self, width, height)
    }
}
