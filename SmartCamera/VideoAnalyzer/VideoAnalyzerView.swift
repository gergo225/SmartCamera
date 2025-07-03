//
//  VideoAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUI

struct VideoAnalyzerView: View {
    @State private var viewModel = VideoAnalyzerViewModel()
    @State private var videoSize: CGSize = .zero

    var body: some View {
        VideoView(onFrameCaptured: {
            viewModel.processFrame($0)
        },
                  videoFrameSize: $videoSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay {
            Canvas { context, _ in
                let yOffset = UIScreen.main.bounds.height - videoSize.height
                let normalizedPoints = viewModel.contourPoints

                context.translateBy(x: 0, y: yOffset / UIScreen.main.scale)
                DrawingUtils.drawNormalizedPointsOnCanvas(context: context, size: videoSize, points: normalizedPoints)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}
