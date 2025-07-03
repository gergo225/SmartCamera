//
//  DrawingUtils.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUICore

class DrawingUtils {
    static func drawNormalizedPointsOnCanvas(context: GraphicsContext, size: CGSize, points normalizedPoints: [CGPoint]) {
        let width = size.width
        let height = size.height
        let lineWidth: CGFloat = 1

        let points = normalizedPoints.map {
            $0.fromNormalizedToRegular(width: Int(width), height: Int(height))
        }
        points.forEach { point in
            let pointPath = Circle().path(in: CGRect(x: point.x, y: size.height - point.y, width: lineWidth, height: lineWidth))
            context.stroke(pointPath, with: .color(.orange), lineWidth: 2)
        }
    }
}
