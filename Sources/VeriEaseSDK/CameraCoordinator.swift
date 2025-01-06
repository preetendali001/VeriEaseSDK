//
//  CameraCoordinator.swift
//  VeriEase
//
//  Created by Preeten Dali on 18/12/24.
//

import Vision
import AVFoundation

class CameraCoordinator: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isMovementDetected = false
    
    private var movementCount = 0
    let requiredMovements = 3
    let movementInterval: TimeInterval = 3.0
    
    private var timer: Timer?
    private var movementStartTime: Date?
    
    private var faceDetectionRequest: VNDetectFaceLandmarksRequest?
    private let faceDetectionSequenceHandler = VNSequenceRequestHandler()
    
    override init() {
        super.init()
        faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: handleFaceDetection)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let request = faceDetectionRequest else { return }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing Vision request: \(error)")
        }
    }
    
    private func handleFaceDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation], let face = observations.first else {
            resetDetection()
            return
        }
        
        let blinking    = detectBlink(face: face)
        let tilting     = detectTilt(face: face)
        
        if blinking || tilting {
            trackMovement()
        }
    }
    
    private func detectBlink(face: VNFaceObservation) -> Bool {
        guard let landmarks = face.landmarks, let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else { return false }
        
        let leftEAR     = calculateEAR(eye: leftEye)
        let rightEAR    = calculateEAR(eye: rightEye)
        let tolerance: CGFloat = 0.1
        let isBlinking = leftEAR < tolerance || rightEAR < tolerance
        return isBlinking
    }
    
    private func calculateEAR(eye: VNFaceLandmarkRegion2D) -> CGFloat {
        guard eye.pointCount >= 6 else { return 1.0 }
        
        let points      = eye.normalizedPoints
        let vertical1   = distance(points1: points[1], points2: points[5])
        let vertical2   = distance(points1: points[2], points2: points[4])
        let horizontal  = distance(points1: points[0], points2: points[3])
        
        return (vertical1 + vertical2) / (2.0 * horizontal)
    }
    
    private func distance(points1: CGPoint, points2: CGPoint) -> CGFloat {
        let dx = abs(points1.x - points2.x)
        let dy = abs(points1.y - points2.y)
        return abs(sqrt((dx * dx) + (dy * dy)))
    }
    
    private func detectTilt(face: VNFaceObservation) -> Bool {
        let tiltAngle = abs(face.yaw?.doubleValue ?? 0.0)
        let isTilting = tiltAngle > 0.5
        return isTilting
    }
    
    private func trackMovement() {
        if movementStartTime == nil {
            movementStartTime = Date()
            startTimer()
        }
        
        movementCount += 1
        
        if movementCount >= requiredMovements {
            DispatchQueue.main.async {
                self.isMovementDetected = true
            }
            resetTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: movementInterval, repeats: false) { [weak self] _ in
            self?.resetDetection()
        }
    }
    
    private func resetDetection() {
        movementCount = 0
        movementStartTime =  nil
        DispatchQueue.main.async {
            self.isMovementDetected = false
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        movementStartTime = nil
    }
}
