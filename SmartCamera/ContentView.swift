//
//  ContentView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 27.06.2025.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var visionManager = VisionManager.shared

    @State private var image: UIImage? = nil
    @State private var normalizedContourPoints: [CGPoint] = []

    var body: some View {
        VStack {
            if let image {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            Canvas { context, size in

                                let width = size.width
                                let height = size.height
                                let lineWidth: CGFloat = 1

                                let contours = normalizedContourPoints.map {
                                    $0.fromNormalizedToRegular(width: Int(width), height: Int(height))
                                }
                                contours.forEach { contour in
                                    let point = Circle().path(in: CGRect(x: contour.x, y: size.height - contour.y, width: lineWidth, height: lineWidth))
                                    context.stroke(point, with: .color(.orange), lineWidth: 2)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                }
            } else {
                Text("Loading image...")
            }
        }
        .padding()
        .task {
            let imageName = "tree_image"

            guard let imageUrl = Bundle.main.url(forResource: imageName, withExtension: "jpg") else {
                print("Can't find image")
                return
            }
            image = UIImage(named: imageName)

            let normalizedPoints = await visionManager.detectImageContours(url: imageUrl)

            normalizedContourPoints = normalizedPoints
            print("Found contours")
        }
    }
}

extension CGPoint {
    func fromNormalizedToRegular(width: Int, height: Int) -> CGPoint {
        return VNImagePointForNormalizedPoint(self, width, height)
    }
}

#Preview {
    ContentView()
}
