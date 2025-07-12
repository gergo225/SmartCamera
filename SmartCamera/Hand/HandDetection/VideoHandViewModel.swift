//
//  VideoHandViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 10.07.2025.
//

import Foundation
import Vision

enum Handedness {
    case left
    case right
}

struct HandItem {
    let handedness: Handedness  // TODO: not sure if this will be used or not (maybe in the future, for drawing - left hand: eraser)
    let joints: [HumanHandPoseObservation.JointName: Joint]
}

@Observable
class VideoHandViewModel {
    var hands: [HandItem] = []
    var isProcessing: Bool = false

    private let visionManager = VisionManager.shared

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        guard !isProcessing else {
            return
        }

        isProcessing = true
        Task { [weak self] in
            guard let self else { return }

            let hands = await visionManager.detectHands(pixelBuffer: pixelBuffer)
            guard !hands.isEmpty else {
                DispatchQueue.main.async { [weak self] in
                    self?.isProcessing = false
                }
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.hands = hands
                self?.isProcessing = false
            }
        }
    }
}
