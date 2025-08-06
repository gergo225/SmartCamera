//
//  ImageFilter.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 23.07.2025.
//

import CoreImage.CIFilterBuiltins

enum ImageFilterType: String, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }

    case blur
    case sepia
    case pixel
    case comic
    case edges
    case crystalize

    var filter: BaseImageFilter {
        switch self {
        case .blur:
            return BlurFilter()
        case .sepia:
            return SepiaFilter()
        case .pixel:
            return PixellateFilter()
        case .comic:
            return ComicFilter()
        case .edges:
            return EdgesFilter()
        case .crystalize:
            return CrystalizeFilter()
        }
    }
}

protocol ImageFilter: Equatable, Hashable, NSObject, Identifiable {
    var title: String { get }
    var parameters: [FilterParameter] { get }
    func applyFilter(to image: CIImage) -> CIImage?
}

extension ImageFilter {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title && lhs.parameters == rhs.parameters
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(parameters)
    }
}

class BaseImageFilter: NSObject, ImageFilter {
    var title: String { "Base Filter" }
    var parameters: [FilterParameter] { [] }
    func applyFilter(to image: CIImage) -> CIImage? {
        return image
    }
}

class BlurFilter: BaseImageFilter {
    override var title: String { "Blur" }
    override var parameters: [FilterParameter] { [radius] }

    var radius = FilterParameter(value: 20, range: 0...100, name: "Radius")

    override func applyFilter(to image: CIImage) -> CIImage? {
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = radius.value

        return blur.outputImage
    }
}

class SepiaFilter: BaseImageFilter {
    override var title: String { "Sepia" }
    override var parameters: [FilterParameter] { [intensity] }

    var intensity = FilterParameter(value: 0.7, range: 0...1, name: "Intensity")

    override func applyFilter(to image: CIImage) -> CIImage? {
        let sepia = CIFilter.sepiaTone()
        sepia.inputImage = image
        sepia.intensity = intensity.value

        return sepia.outputImage
    }
}

class PixellateFilter: BaseImageFilter {
    override var title: String { "Pixellate" }
    override var parameters: [FilterParameter] { [scale] }

    var scale = FilterParameter(value: 10, range: 1...60, name: "Scale")

    override func applyFilter(to image: CIImage) -> CIImage? {
        let pixel = CIFilter.pixellate()
        pixel.inputImage = image
        pixel.center = CGPoint(x: 150, y: 150)
        pixel.scale = scale.value

        return pixel.outputImage
    }
}

class ComicFilter: BaseImageFilter {
    override var title: String { "Comicbook" }
    override var parameters: [FilterParameter] { [] }

    override func applyFilter(to image: CIImage) -> CIImage? {
        let comic = CIFilter.comicEffect()
        comic.inputImage = image

        return comic.outputImage
    }
}

class EdgesFilter: BaseImageFilter {
    override var title: String { "Edges" }
    override var parameters: [FilterParameter] { [radius] }

    var radius = FilterParameter(value: 5, range: 1...20, name: "Radius")

    override func applyFilter(to image: CIImage) -> CIImage? {
        let edges = CIFilter.edgeWork()
        edges.inputImage = image
        edges.radius = radius.value

        return edges.outputImage
    }
}

class CrystalizeFilter: BaseImageFilter {
    override var title: String { "Crystalize" }
    override var parameters: [FilterParameter] { [radius] }

    var radius = FilterParameter(value: 30, range: 5...100, name: "Radius")

    override func applyFilter(to image: CIImage) -> CIImage? {
        let crystalize = CIFilter.crystallize()
        crystalize.inputImage = image
        crystalize.radius = radius.value

        return crystalize.outputImage
    }
}
