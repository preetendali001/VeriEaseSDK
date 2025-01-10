//
//  VisionService.swift
//  VeriEase
//
//  Created by Preeten Dali on 12/12/24.
//

import UIKit
import Vision

class VisionService {
    
    var similarityScore = 0
    
    func detectFaces(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            print("Failed to create CIImage from UIImage.")
            completion("Error processing image.")
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                print("Face detection failed: \(error.localizedDescription)")
                completion("Error detecting faces.")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                completion(nil)
                return
            }
            
            if observations.count > 1 {
                completion("Multiple faces detected.")
                return
            }
            
            completion(nil)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing face detection: \(error.localizedDescription)")
            completion("Error detecting faces.")
        }
    }
    
    func detectFaceLandmarks(image: UIImage, completion: @escaping (VNFaceObservation?) -> Void) {
        guard let cgImage = image.cgImage else {
            print("Error: Unable to get CGImage from UIImage.")
            completion(nil)
            return
        }
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                print("No face observations detected.")
                completion(nil)
                return
            }
            
            let alignedFace = self.alignFace(faceObservation:observations.first!, image: cgImage)
            completion(alignedFace)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([faceDetectionRequest])
        } catch {
            print("Error performing face detection request: \(error)")
            completion(nil)
        }
    }
    
    func compareFaces(licenseFace: VNFaceObservation, liveFace: VNFaceObservation) -> Bool {
        guard let licenseLandmarks = licenseFace.landmarks,
              let liveLandmarks = liveFace.landmarks else {
            print("Error: Missing landmarks in one of the face observations.")
            return false
        }
        
        let landmarksToCompare: [(VNFaceLandmarkRegion2D?, VNFaceLandmarkRegion2D?)] = [
            (licenseLandmarks.nose, liveLandmarks.nose),
            (licenseLandmarks.leftEye, liveLandmarks.leftEye),
            (licenseLandmarks.rightEye, liveLandmarks.rightEye),
            (licenseLandmarks.outerLips, liveLandmarks.outerLips),
            (licenseLandmarks.innerLips, liveLandmarks.innerLips),
            (licenseLandmarks.leftPupil, liveLandmarks.leftPupil),
            (licenseLandmarks.rightPupil, liveLandmarks.rightPupil),
            (licenseLandmarks.faceContour, liveLandmarks.faceContour)
        ]
        
        for (landmark1, landmark2) in landmarksToCompare {
            if compareLandmark(landmark1: landmark1, landmark2: landmark2) {
                similarityScore += 1
            }
        }
        
        let threshold = Int(0.75 * Double(landmarksToCompare.count))
        return similarityScore >= threshold
    }
    
    private func compareLandmark(landmark1: VNFaceLandmarkRegion2D?, landmark2: VNFaceLandmarkRegion2D?) -> Bool {
        guard let points1 = landmark1?.normalizedPoints,
              let points2 = landmark2?.normalizedPoints,
              points1.count == points2.count else {
            return false
        }
        
        let tolerance: CGFloat = 0.04
        var totalDistance: CGFloat = 0.0
        
        for i in 0..<points1.count {
            let dx = points1[i].x - points2[i].x
            let dy = points1[i].y - points2[i].y
            totalDistance += sqrt(dx * dx + dy * dy)
        }
        
        let averageDistance = totalDistance / CGFloat(points1.count)
        return averageDistance <= tolerance
    }
    
    func alignFace(faceObservation: VNFaceObservation, image: CGImage) -> VNFaceObservation? {
        let alignmentRequest = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([alignmentRequest])
            guard let observations = alignmentRequest.results else {
                return nil
            }
            return observations.first
        } catch {
            print("Error aligning face: \(error)")
            return nil
        }
    }
    
    func detectGlasses(face: VNFaceObservation) -> Bool {
        guard let landmarks = face.landmarks else { return false }
        if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
            
            let leftEyePoints = leftEye.normalizedPoints
            let rightEyePoints = rightEye.normalizedPoints
            
            if leftEyePoints.count > 2 && rightEyePoints.count > 2 {
                let leftEyeX = leftEyePoints[0].x
                let rightEyeX = rightEyePoints[0].x
                let eyeDistance = abs(leftEyeX - rightEyeX)
                return eyeDistance < 0.2
            }
        }
        return false
    }
}
