//
//  ImageFilter.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 23.07.2025.
//

import CoreImage.CIFilterBuiltins

enum ImageFilter: String, CaseIterable, Identifiable {
    case blur
    case sepia
    case pixel
    case comic
    case edges
    case crystalize

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blur:
            "Blur"
        case .sepia:
            "Sepia"
        case .pixel:
            "Pixellate"
        case .comic:
            "Comicbook"
        case .edges:
            "Edges"
        case .crystalize:
            "Crystalize"
        }
    }
}
