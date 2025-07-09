//
//  FaceLandmark.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 09.07.2025.
//

import SwiftUI
import Vision

struct FaceLandmark: Shape {
    let region: FaceObservation.Landmarks2D.Region

    func path(in rect: CGRect) -> Path {
        let points = region.pointsInImageCoordinates(rect.size, origin: .upperLeft)
        let path = CGMutablePath()

        path.move(to: points[0])

        for index in 1..<points.count {
            path.addLine(to: points[index])
        }

        if region.pointsClassification == .closedPath {
            path.closeSubpath()
        }

        return Path(path)
    }
}
