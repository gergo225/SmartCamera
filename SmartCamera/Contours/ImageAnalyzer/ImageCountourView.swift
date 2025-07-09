//
//  ImageAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 28.06.2025.
//

import SwiftUI
import Vision
import PhotosUI

struct ImageContourView: View {
    @State private var viewModel = ImageContourViewModel()
    @State private var shouldShowDetailedContours = false
    @State private var selectedImage: PhotosPickerItem?

    var body: some View {
        VStack {
            if let photo = viewModel.photo {
                ZStack {
                    Image(uiImage: photo)
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
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
                .onChange(of: selectedImage) { _, newImage in
                    guard let newImage else { return }
                    viewModel.analyzeImage(photo: newImage, showDetails: shouldShowDetailedContours)
                }
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
            guard let selectedImage else { return }
            viewModel.analyzeImage(photo: selectedImage, showDetails: newValue)
        }
    }
}

extension CGPoint {
    func fromNormalizedToRegular(width: Int, height: Int) -> CGPoint {
        return VNImagePointForNormalizedPoint(self, width, height)
    }
}
