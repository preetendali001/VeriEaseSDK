//
//  VisionService.swift
//  VeriEase
//
//  Created by Preeten Dali on 12/12/24.
//

import UIKit
import Vision

public class VisionService {

    public init() {}

    public func detectFaceLandmarks(image: UIImage, completion: @escaping (VNFaceObservation?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                print("Face detection Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion((request.results as? [VNFaceObservation])?.first)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing image request: \(error)")
            completion(nil)
        }
    }
    
    public func compareFaces(licenseFace: VNFaceObservation, liveFace: VNFaceObservation) -> Bool {
        guard let licenseLandmarks = licenseFace.landmarks,
              let liveLandmarks = liveFace.landmarks else {
            return false
        }
        
        let noseMatch = compareLandmark(landmark1: licenseLandmarks.nose, landmark2: liveLandmarks.nose)
        let leftEyeMatch = compareLandmark(landmark1: licenseLandmarks.leftEye, landmark2: liveLandmarks.leftEye)
        let rightEyeMatch = compareLandmark(landmark1: licenseLandmarks.rightEye, landmark2: liveLandmarks.rightEye)
        let leftPupilMatch = compareLandmark(landmark1: licenseLandmarks.leftPupil, landmark2: liveLandmarks.leftPupil)
        let rightPupilMatch = compareLandmark(landmark1: licenseLandmarks.rightPupil, landmark2: liveLandmarks.rightPupil)
        
        let conditionsMet = noseMatch && leftEyeMatch && rightEyeMatch && leftPupilMatch && rightPupilMatch
        
        return conditionsMet
    }
    
    private func compareLandmark(landmark1: VNFaceLandmarkRegion2D?, landmark2: VNFaceLandmarkRegion2D?) -> Bool {
        
        guard let points1 = landmark1?.normalizedPoints,
              let points2 = landmark2?.normalizedPoints,
              points1.count == points2.count else {
            return false
        }
        
        let tolerance: CGFloat = 0.05
        for i in 0..<points1.count {
            let dx = abs(points1[i].x - points2[i].x)
            let dy = abs(points1[i].y - points2[i].y)
            if dx > tolerance || dy > tolerance {
                return false
            }
        }
        return true
    }
}
