//
//  FilterParameter.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 28.07.2025.
//

import Foundation

struct FilterParameter: Hashable, Identifiable {
    var id: UUID { UUID() }

    var value: Float
    let range: ClosedRange<Float>
    var name: String
}
