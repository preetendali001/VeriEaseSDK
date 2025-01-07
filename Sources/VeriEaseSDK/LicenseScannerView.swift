//
//  LicenseScannerView.swift
//  VeriEase
//
//  Created by Preeten Dali on 12/12/24.
//

import SwiftUI
import AVFoundation

struct LicenseScannerView: View {
    var onScanned: (UIImage) -> Void
    
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var captureSession: AVCaptureSession?
    @State private var photoOutput: AVCapturePhotoOutput?
    @State private var isCameraReady = false
    @State private var photoCaptureDelegate: PhotoCaptureDelegate?
    @State private var focusPoint: CGPoint?
    @State private var showFocusIndicator = false
    
    public init(onScanned: @escaping (UIImage) -> Void) {
        self.onScanned = onScanned
    }
    
    var body: some View {
        ZStack {
            if isCameraReady, let previewLayer = previewLayer {
                CameraPreview(previewLayer: previewLayer)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { gesture in
                                let location = gesture.location
                                let screenSize = UIScreen.main.bounds.size
                                let normalizedPoint = CGPoint(x: location.x / screenSize.width, y: location.y / screenSize.height)
                                focusCamera(point: normalizedPoint)
                                focusPoint = location
                                showFocusIndicator = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    showFocusIndicator = false
                                }
                            }
                    )
            } else {
                Text("Loading camera...")
                    .onAppear { setupCamera() }
            }
            
            if showFocusIndicator, let focusPoint = focusPoint {
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 70, height: 70)
                    .position(focusPoint)
                    .scaleEffect(showFocusIndicator ? 1.5 : 1)
                    .opacity(showFocusIndicator ? 0.8 : 0)
                    .shadow(color: Color.green, radius: 10, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.4), value: showFocusIndicator)
            }
            
            VStack {
                Spacer()
                Button(action: capturePhoto) {
                    Text("Capture License")
                        .padding()
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onDisappear { stopCameraSession() }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No back camera found.")
            return
        }
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
        } else {
            print("Failed to add photo output")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            DispatchQueue.main.async {
                self.captureSession = session
                self.isCameraReady = true
            }
        }
    }
    
    private func stopCameraSession() {
        captureSession?.stopRunning()
    }
    
    private func capturePhoto() {
        guard let captureSession = captureSession, captureSession.isRunning else {
            print("Capture session is not running")
            return
        }
        
        guard let photoOutput = photoOutput else {
            print("Photo output is not available")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        let delegate = PhotoCaptureDelegate { image in
            if let capturedImage = image {
                onScanned(capturedImage)
            } else {
                print("Failed to capture image")
            }
        }
        
        self.photoCaptureDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    private func focusCamera(point: CGPoint) {
        let videoDevice: AVCaptureDevice?
        if let tripalCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            videoDevice = tripalCamera
        } else if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            videoDevice = dualCamera
        } else if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            videoDevice = wideCamera
        } else {
            print("No compatible camera found.")
            return
        }
        guard let captureSession = captureSession, captureSession.isRunning else {
            print("Capture session is not running.")
            return
        }
        do {
            try videoDevice?.lockForConfiguration()
            
            if let videoDevice = videoDevice, videoDevice.isFocusPointOfInterestSupported {
                videoDevice.focusPointOfInterest = point
                videoDevice.focusMode = .autoFocus
            }
            
            if let videoDevice = videoDevice, videoDevice.isExposurePointOfInterestSupported {
                videoDevice.exposurePointOfInterest = point
                videoDevice.exposureMode = .autoExpose
            }
            videoDevice?.unlockForConfiguration()
        } catch {
            print("Failed to configure focus: \(error)")
        }
    }
}
