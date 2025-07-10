//
//  VisionManager.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 27.06.2025.
//
import Vision
import CoreImage

final class VisionManager {
    static let shared = VisionManager()

    func detectImageContours(data: Data, showNestedContours: Bool = false) async -> [CGPoint] {
        let imageHandler = VNImageRequestHandler(data: data)
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

    func detectImageForegroundMask(data: Data) async -> CIImage? {
        let imageHandler = VNImageRequestHandler(data: data)
        return await detectImageForegroundMask(handler: imageHandler)
    }

    private func detectImageForegroundMask(handler: VNImageRequestHandler) async -> CIImage? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let request = VNGenerateForegroundInstanceMaskRequest { request, error in
                    if let error {
                        print("Error generating foreground mask: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }

                    guard let result = request.results?.first as? VNInstanceMaskObservation else {
                        print("No foreground subjects were found")
                        continuation.resume(returning: nil)
                        return
                    }

                    do {
                        let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                        let maskImage = CIImage(cvPixelBuffer: mask)
                        continuation.resume(returning: maskImage)
                    } catch {
                        print("Failed to generate mask: \(error.localizedDescription)")
                        continuation.resume(returning: nil)
                    }
                }

                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform request: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Failed to detect foreground mask: \(error.localizedDescription)")
            return nil
        }
    }

    func detectFaces(data: Data) async -> [FaceItem] {
        do {
            let imageHandler = ImageRequestHandler(data)

            let detectFacesRequest = DetectFaceRectanglesRequest()

            let faceObservations = try await imageHandler.perform(detectFacesRequest)

            var detectLandmarksRequest = DetectFaceLandmarksRequest()
            detectLandmarksRequest.inputFaceObservations = faceObservations

            let faceLandmarks = try await imageHandler.perform(detectLandmarksRequest)
            let faceRectangles = faceObservations.map { $0.boundingBox }

            return zip(faceRectangles, faceLandmarks).map { FaceItem(normalizedRect: $0, landmarkObservation: $1) }
        } catch {
            print("Failed to detect face: \(error.localizedDescription)")
            return []
        }
    }

    func detectHands(pixelBuffer: CVPixelBuffer) async -> [HandItem] {
        do {
            let imageHandler = ImageRequestHandler(pixelBuffer)

            let detectHandsRequest = DetectHumanHandPoseRequest()

            let handObservations = try await imageHandler.perform(detectHandsRequest)

            let detectedHandPoses = handObservations.map { handObservation in
                let handedness: Handedness = handObservation.chirality == .left ? .left : .right
                let joints = handObservation.allJoints()

                return HandItem(handedness: handedness, joints: joints)
            }

            return detectedHandPoses
        } catch {
            print("Failed to detect hand: \(error.localizedDescription)")
            return []
        }
    }
}
