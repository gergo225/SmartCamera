//
//  HandDrawingView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 11.07.2025.
//

import SwiftUI

struct HandDrawingView: View {
    @State private var viewModel = HandDrawingViewModel()
    @State private var videoSize: CGSize = .zero
    @State private var videoOffset: CGPoint = .zero

    @State private var shouldShowHandBoundingBox: Bool = false

    private let pointSize = CGSize(width: 8, height: 8)

    var body: some View {
        VideoView(
            onFrameCaptured: {
                viewModel.processFrame($0)
            },
            cameraType: .front,
            videoFrameSize: $videoSize,
            videoFrameOffset: $videoOffset
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay {
            Canvas { context, _ in
                context.translateBy(x: videoOffset.x, y: videoOffset.y)

                viewModel.drawnPoints.forEach { normalizedPoint in
                    let pointLocation = normalizedPoint.toImageCoordinates(videoSize, origin: .upperLeft)
                    let point = Circle().path(in: CGRect(origin: pointLocation, size: pointSize))

                    context.fill(point, with: .color(.red))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .overlay {
            if shouldShowHandBoundingBox, let handRect = viewModel.handRect {
                BoundingBox(normalizedRect: handRect)
                    .stroke(.blue, lineWidth: 10)
                    .offset(x: videoOffset.x, y: videoOffset.y)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Toggle("Hand Bounding Box", isOn: $shouldShowHandBoundingBox)
            }
        }
    }
}
