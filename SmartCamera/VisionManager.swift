//
//  VisionManager.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 27.06.2025.
//
import Vision

final class VisionManager {
    static let shared = VisionManager()

    func detectImageContours(url: URL) async -> [CGPoint] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let request = VNDetectContoursRequest { request, error in
                    if let error {
                        print("Error detecting contours: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }

                    if let results = request.results as? [VNContoursObservation] {
//                        let paths = results.flatMap { $0.topLevelContours }.map { $0.normalizedPath }

                        // TODO: this gets contours that are inside other contours too (aka. nested contours)
//                        let contours = results.flatMap { contour in
//                            (0..<contour.contourCount).map { index in
//                                try? contour.contour(at: index)
//                            }
//                        }

                        let contours: [VNContour?] = results.flatMap { contour in
                            contour.topLevelContours
                        }

                        let points = contours.compactMap {
                            $0?.normalizedPoints.map {
                                CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))
                            } ?? []
                        }.flatMap { $0 }
                        continuation.resume(returning: points)
                    }
                }

                let handler = VNImageRequestHandler(url: url)

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
