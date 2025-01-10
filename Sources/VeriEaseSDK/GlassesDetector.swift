//
//  GlassesDetector.swift
//  VeriEase
//
//  Created by Preeten Dali  on 10/01/25.
//

import Foundation
import Vision

class GlassesDetector {
    
    struct GlassesDetectionResult {
        let hasGlasses: Bool
        let confidence: Float
        let details: [String: Any]
    }
    
    private let edgeIntensityThreshold: Float = 0.6
    private let glassesFrameWidthRatio: Float = 0.15
    private let minConfidenceThreshold: Float = 0.4
    
    func detectGlasses(face: VNFaceObservation) -> GlassesDetectionResult {
        var confidenceScores: [Float] = []
        var details: [String: Any] = [:]
        
        guard let landmarks = face.landmarks else {
            return GlassesDetectionResult(hasGlasses: false, confidence: 0.0, details: ["error": "No landmarks detected"])
        }
        
        if let geometryScore = analyzeEyeRegionGeometry(landmarks: landmarks) {
            confidenceScores.append(geometryScore)
            details["geometryScore"] = geometryScore
        }
        
        if let edgeScore = detectFrameEdges(face: face, landmarks: landmarks) {
            confidenceScores.append(edgeScore)
            details["edgeScore"] = edgeScore
        }
        
        if let brightnessScore = analyzeBrightnessDistribution(face: face, landmarks: landmarks) {
            confidenceScores.append(brightnessScore)
            details["brightnessScore"] = brightnessScore
        }
        
        let finalConfidence = calculateWeightedConfidence(scores: confidenceScores)
        details["finalConfidence"] = finalConfidence
        
        return GlassesDetectionResult(
            hasGlasses: finalConfidence >= minConfidenceThreshold,
            confidence: finalConfidence,
            details: details
        )
    }
    
    private func analyzeEyeRegionGeometry(landmarks: VNFaceLandmarks2D) -> Float? {
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye,
              let leftEyebrow = landmarks.leftEyebrow,
              let rightEyebrow = landmarks.rightEyebrow else {
            return nil
        }
        
        let leftEyePoints = leftEye.normalizedPoints
        let rightEyePoints = rightEye.normalizedPoints
        let leftEyebrowPoints = leftEyebrow.normalizedPoints
        let rightEyebrowPoints = rightEyebrow.normalizedPoints
        
        let leftEyeCenter = calculateCentroid(points: leftEyePoints)
        let rightEyeCenter = calculateCentroid(points: rightEyePoints)
        let leftEyebrowCenter = calculateCentroid(points: leftEyebrowPoints)
        let rightEyebrowCenter = calculateCentroid(points: rightEyebrowPoints)
        
        let leftDistance = distance(point1: leftEyeCenter, point2: leftEyebrowCenter)
        let rightDistance = distance(point1: rightEyeCenter, point2: rightEyebrowCenter)
        
        let averageDistance = (leftDistance + rightDistance) / 2
        return normalizeScore(value:CGFloat(averageDistance), expectedMin: 0.05, expectedMax: 0.15)
    }
    
    private func detectFrameEdges(face: VNFaceObservation, landmarks: VNFaceLandmarks2D) -> Float? {
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return nil
        }
        
        let eyeRegionWidth = abs(rightEye.normalizedPoints[0].x - leftEye.normalizedPoints[0].x)
        return normalizeScore(value:eyeRegionWidth, expectedMin: 0.2, expectedMax: 0.4)
    }
    
    private func analyzeBrightnessDistribution(face: VNFaceObservation, landmarks: VNFaceLandmarks2D) -> Float? {
        return 0.8
    }
    
    private func calculateWeightedConfidence(scores: [Float]) -> Float {
        guard !scores.isEmpty else { return 0.0 }
        
        let weights: [Float] = [0.4, 0.4, 0.2]
        
        var weightedSum: Float = 0.0
        var weightSum: Float = 0.0
        
        for (index, score) in scores.enumerated() {
            if index < weights.count {
                weightedSum += score * weights[index]
                weightSum += weights[index]
            }
        }
        
        return weightSum > 0 ? weightedSum / weightSum : 0.0
    }
    
    private func calculateCentroid(points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        
        let sum = points.reduce(CGPoint.zero) { result, point in
            CGPoint(x: result.x + point.x, y: result.y + point.y)
        }
        
        return CGPoint(x: sum.x / CGFloat(points.count),
                      y: sum.y / CGFloat(points.count))
    }
    
    private func distance(point1: CGPoint, point2: CGPoint) -> Float {
        let dx = Float(point2.x - point1.x)
        let dy = Float(point2.y - point1.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    private func normalizeScore(value: CGFloat, expectedMin: CGFloat, expectedMax: CGFloat) -> Float? {
        let normalized = (value - expectedMin) / (expectedMax - expectedMin)
        return min(Float(max(normalized, 0)), 1)
    }
}
