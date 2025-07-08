//
//  BoundingBox.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 08.07.2025.
//

import SwiftUI
import Vision

struct BoundingBox: Shape {
    let normalizedRect: NormalizedRect

    func path(in rect: CGRect) -> Path {
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}
