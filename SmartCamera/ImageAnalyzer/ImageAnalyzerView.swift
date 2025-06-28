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
                                drawNormalizedPointsOnCanvas(context: context, size: size, points: normalizedPoints)
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

    private func drawNormalizedPointsOnCanvas(context: GraphicsContext, size: CGSize, points normalizedPoints: [CGPoint]) {
        let width = size.width
        let height = size.height
        let lineWidth: CGFloat = 1

        let points = normalizedPoints.map {
            $0.fromNormalizedToRegular(width: Int(width), height: Int(height))
        }
        points.forEach { point in
            let pointPath = Circle().path(in: CGRect(x: point.x, y: size.height - point.y, width: lineWidth, height: lineWidth))
            context.stroke(pointPath, with: .color(.orange), lineWidth: 2)
        }
    }
}

extension CGPoint {
    func fromNormalizedToRegular(width: Int, height: Int) -> CGPoint {
        return VNImagePointForNormalizedPoint(self, width, height)
    }
}
