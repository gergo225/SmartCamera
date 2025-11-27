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

    var filter: any ImageFilter {
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

    var title: String {
        switch self {
        case .blur:
            "Blur"
        case .sepia:
            "Sepia"
        case .pixel:
            "Pixellate"
        case .comic:
            "Comic"
        case .edges:
            "Edges"
        case .crystalize:
            "Crystalize"
        }
    }
}

protocol ImageFilter: Equatable, Hashable, NSObject, Identifiable {
    associatedtype Parameters: ImageFilterParameters

    var filterType: ImageFilterType { get }
    var parameters: Parameters { get set }
    func applyFilter(to image: CIImage) -> CIImage?
}

extension ImageFilter {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension ImageFilter {
    var title: String {
        filterType.title
    }
}

protocol ImageFilterParameters: MutableCollection, RandomAccessCollection {
    var parameters: [FilterParameter] { get set }
}

extension ImageFilterParameters {
    var startIndex: Int {
        parameters.startIndex
    }

    var endIndex: Int {
        parameters.endIndex
    }

    subscript(position: Int) -> FilterParameter {
        get { parameters[position] }
        set { parameters[position] = newValue }
    }

    func index(after i: Int) -> Int {
        parameters.index(after: i)
    }
}




class BlurFilter: NSObject, ImageFilter {
    struct Parameters: ImageFilterParameters {
        var parameters: [FilterParameter]
        var radius: FilterParameter

        init() {
            self.radius = FilterParameter(value: 20, range: 0...100, name: "Radius")
            self.parameters = [radius]
        }
    }

    var filterType: ImageFilterType = .blur

    var parameters: Parameters = Parameters()

    func applyFilter(to image: CIImage) -> CIImage? {
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = parameters.radius.value

        return blur.outputImage
    }
}

class SepiaFilter: NSObject, ImageFilter {
    struct Parameters: ImageFilterParameters {
        let intensity: FilterParameter
        var parameters: [FilterParameter]

        init() {
            self.intensity = FilterParameter(value: 0.7, range: 0...1, name: "Intensity")
            self.parameters = [intensity]
        }
    }

    var filterType: ImageFilterType = .sepia

    var parameters: Parameters = Parameters()

    func applyFilter(to image: CIImage) -> CIImage? {
        let sepia = CIFilter.sepiaTone()
        sepia.inputImage = image
        sepia.intensity = parameters.intensity.value

        return sepia.outputImage
    }
}

class PixellateFilter: NSObject, ImageFilter {
    struct Parameters: ImageFilterParameters {
        let scale: FilterParameter
        var parameters: [FilterParameter]

        init() {
            self.scale = FilterParameter(value: 10, range: 1...60, name: "Scale")
            self.parameters = [scale]
        }
    }

    var filterType: ImageFilterType = .pixel

    var parameters: Parameters = Parameters()

    func applyFilter(to image: CIImage) -> CIImage? {
        let pixel = CIFilter.pixellate()
        pixel.inputImage = image
        pixel.center = CGPoint(x: 150, y: 150)
        pixel.scale = parameters.scale.value

        return pixel.outputImage
    }
}

class ComicFilter: NSObject, ImageFilter {
    struct Parameters: ImageFilterParameters {
        var parameters: [FilterParameter]

        init() {
            self.parameters = []
        }
    }

    var filterType: ImageFilterType = .comic

    var parameters: Parameters = Parameters()

    func applyFilter(to image: CIImage) -> CIImage? {
        let comic = CIFilter.comicEffect()
        comic.inputImage = image

        return comic.outputImage
    }
}

class EdgesFilter: NSObject, ImageFilter {
    struct Parameters: ImageFilterParameters {
        let radius: FilterParameter
        var parameters: [FilterParameter]

        init() {
            self.radius = FilterParameter(value: 5, range: 1...20, name: "Radius")
            self.parameters = [radius]
        }
    }

    var filterType: ImageFilterType = .edges

    var parameters: Parameters = Parameters()

    func applyFilter(to image: CIImage) -> CIImage? {
        let edges = CIFilter.edgeWork()
        edges.inputImage = image
        edges.radius = parameters.radius.value

        return edges.outputImage
    }
}

class CrystalizeFilter: NSObject, ImageFilter {
    struct Parameters: ImageFilterParameters {
        let radius: FilterParameter
        var parameters: [FilterParameter]

        init() {
            self.radius = FilterParameter(value: 30, range: 5...100, name: "Radius")
            self.parameters = [radius]
        }
    }

    var filterType: ImageFilterType = .crystalize

    var parameters: Parameters = Parameters()

    func applyFilter(to image: CIImage) -> CIImage? {
        let crystalize = CIFilter.crystallize()
        crystalize.inputImage = image
        crystalize.radius = parameters.radius.value

        return crystalize.outputImage
    }
}
