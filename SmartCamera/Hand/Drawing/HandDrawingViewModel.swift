//
//  HandDrawingViewModel.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 11.07.2025.
//

import Vision

@Observable
class HandDrawingViewModel {
    var drawnPoints: [NormalizedPoint] = []

    private var isProcessing: Bool = false
    private let visionManager = VisionManager.shared

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
//        guard !isProcessing else {
//            return
//        }

        isProcessing = true
        Task { [weak self] in
            guard let self else { return }

            let hands = await visionManager.detectHands(pixelBuffer: pixelBuffer)
            guard let hand = hands.first else {
                DispatchQueue.main.async { [weak self] in
                    self?.isProcessing = false
                }
                return
            }

            let isDrawing = areIndexFingerAndThumbTipsTouching(joints: hand.joints)
            guard isDrawing,
                  let pointToDraw = middleBetweenIndexFingerAndThumbTip(joints: hand.joints) else {
                DispatchQueue.main.async { [weak self] in
                    self?.isProcessing = false
                }
                return
            }

            var previousDrawnPoints = drawnPoints
            previousDrawnPoints.append(pointToDraw)
            let newDrawnPoints = previousDrawnPoints

            DispatchQueue.main.async { [weak self] in
                self?.drawnPoints = newDrawnPoints
                self?.isProcessing = false
            }
        }
    }

    func areIndexFingerAndThumbTipsTouching(joints: [HumanHandPoseObservation.JointName: Joint]) -> Bool {
        guard let indexFingerTip = joints[.indexTip],
              let thumbTip = joints[.thumbTip] else {
            return false
        }

        let distance = indexFingerTip.distance(to: thumbTip)
        let distanceThreshold = 0.05

        return distance < distanceThreshold
    }

    func middleBetweenIndexFingerAndThumbTip(joints: [HumanHandPoseObservation.JointName: Joint]) -> NormalizedPoint? {
        guard let indexFingerTip = joints[.indexTip],
              let thumbTip = joints[.thumbTip] else {
            return nil
        }

        let x: CGFloat = (indexFingerTip.location.x + thumbTip.location.x) / 2
        let y: CGFloat = (indexFingerTip.location.y + thumbTip.location.y) / 2
        return NormalizedPoint(x: x, y: y)
    }
}
