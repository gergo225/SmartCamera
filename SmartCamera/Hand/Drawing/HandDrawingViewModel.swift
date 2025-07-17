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
    var handRect: NormalizedRect?

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

            if let handRect = handJointsNormalizedRect(joints: Array(hand.joints.values)) {
                DispatchQueue.main.async { [weak self] in
                    self?.handRect = handRect
                }
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

    private func areIndexFingerAndThumbTipsTouching(joints: [HumanHandPoseObservation.JointName: Joint]) -> Bool {
        guard let indexFingerTip = joints[.indexTip],
              let thumbTip = joints[.thumbTip] else {
            return false
        }

        let distance = indexFingerTip.distance(to: thumbTip)
        guard let handRect else {
            return false
        }
        let handSize = (handRect.width + handRect.height) / 2
        let distanceThreshold = 0.15 * handSize

        return distance < distanceThreshold
    }

    private func handJointsNormalizedRect(joints: [Joint]) -> NormalizedRect? {
        let jointPoints = joints.map { $0.location }

        guard let xMin = jointPoints.min(by: { $0.x < $1.x })?.x,
              let xMax = jointPoints.max(by: { $0.x < $1.x })?.x,
              let yMin = jointPoints.min(by: { $0.y < $1.y })?.y,
              let yMax = jointPoints.max(by: { $0.y < $1.y })?.y else {
            return nil
        }

        return NormalizedRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
    }

    private func middleBetweenIndexFingerAndThumbTip(joints: [HumanHandPoseObservation.JointName: Joint]) -> NormalizedPoint? {
        guard let indexFingerTip = joints[.indexTip],
              let thumbTip = joints[.thumbTip] else {
            return nil
        }

        let x: CGFloat = (indexFingerTip.location.x + thumbTip.location.x) / 2
        let y: CGFloat = (indexFingerTip.location.y + thumbTip.location.y) / 2
        return NormalizedPoint(x: x, y: y)
    }
}
