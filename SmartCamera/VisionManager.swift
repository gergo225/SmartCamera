//
//  VisionManager.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 27.06.2025.
//
import Vision

final class VisionManager {
    static let shared = VisionManager()

    func detectImageContours(url: URL, showNestedContours: Bool = false) async -> [CGPoint] {
        let imageHandler = VNImageRequestHandler(url: url)
        return await detectImageContours(handler: imageHandler, showNestedContours: showNestedContours)
    }

    func detectImageContours(pixelBuffer: CVPixelBuffer, showNestedContours: Bool = false) async -> [CGPoint] {
        let pixelBufferHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        return await detectImageContours(handler: pixelBufferHandler, showNestedContours: showNestedContours)
    }

    private func detectImageContours(handler: VNImageRequestHandler, showNestedContours: Bool) async -> [CGPoint] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let request = VNDetectContoursRequest { request, error in
                    if let error {
                        print("Error detecting contours: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }

                    if let results = request.results as? [VNContoursObservation] {
                        let contours: [VNContour?] = results.flatMap { contour in
                            if showNestedContours {
                                (0..<contour.contourCount).map { index in
                                    try? contour.contour(at: index)
                                }
                            } else {
                                contour.topLevelContours
                            }
                        }

                        let points = contours.compactMap {
                            $0?.normalizedPoints.map {
                                CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))
                            } ?? []
                        }.flatMap { $0 }
                        continuation.resume(returning: points)
                    }
                }


                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform request: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Failed to detect contours: \(error.localizedDescription)")
            return []
        }
    }
}
