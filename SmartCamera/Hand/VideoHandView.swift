//
//  VideoHandView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 10.07.2025.
//

import SwiftUI

struct VideoHandView: View {
    @State private var viewModel = VideoHandViewModel()
    @State private var videoSize: CGSize = .zero
    @State private var videoOffset: CGPoint = .zero

    private let pointSize = CGSize(width: 3, height: 3)

    var body: some View {
        VideoView(
            onFrameCaptured: {
                viewModel.processFrame($0)
            },
            videoFrameSize: $videoSize,
            videoFrameOffset: $videoOffset
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay {
            Canvas { context, size in
                viewModel.hands.forEach { hand in
                    hand.joints.forEach { _, joint in
                        let jointLocation = joint.location.toImageCoordinates(size, origin: .upperLeft)
                        // TODO: fix: points not drawn exactly on video preview
                        let point = Circle().path(in: CGRect(origin: jointLocation, size: pointSize))

                        context.fill(point, with: .color(.red))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
