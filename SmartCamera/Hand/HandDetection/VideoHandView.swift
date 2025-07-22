//
//  VideoHandView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 10.07.2025.
//

import SwiftUI

struct VideoHandView: View {
    @State private var viewModel = VideoHandViewModel()
    @State private var cameraManager = CameraManager()
    @State private var videoSize: CGSize = .zero
    @State private var videoOffset: CGPoint = .zero

    private let pointSize = CGSize(width: 8, height: 8)

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
                context.translateBy(x: videoOffset.x, y: videoOffset.y)

                viewModel.hands.forEach { hand in
                    hand.joints.forEach { _, joint in
                        let jointLocation = joint.location.toImageCoordinates(videoSize, origin: .upperLeft)
                        let point = Circle().path(in: CGRect(origin: jointLocation, size: pointSize))

                        context.fill(point, with: .color(.red))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
