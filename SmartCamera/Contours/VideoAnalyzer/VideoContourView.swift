//
//  VideoAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUI

struct VideoContourView: View {
    @State private var viewModel = VideoContourViewModel()
    @State private var cameraManager = CameraManager()
    @State private var videoSize: CGSize = .zero
    @State private var videoOffset: CGPoint = .zero

    var body: some View {
        VideoView(
            onFrameCaptured: {
                viewModel.processFrame($0)
            },
            cameraType: .constant(.back),
            videoFrameSize: $videoSize,
            videoFrameOffset: $videoOffset,
            cameraSource: cameraManager
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay {
            Canvas { context, _ in
                let normalizedPoints = viewModel.contourPoints

                context.translateBy(x: videoOffset.x, y: videoOffset.y)
                DrawingUtils.drawNormalizedPointsOnCanvas(context: context, size: videoSize, points: normalizedPoints)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}
