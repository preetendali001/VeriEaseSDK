//
//  LivePhotoCaptureView.swift
//  VeriEase
//
//  Created by Preeten Dali on 12/12/24.
//

import SwiftUI
import AVFoundation

public struct LivePhotoCaptureView: View { // Make the struct public
    
    public var onCapture: (UIImage) -> Void // Make the closure public

    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var photoOutput: AVCapturePhotoOutput?
    @State private var isCameraReady = false
    @State private var currentDevice: AVCaptureDevice?
    @State private var currentDevicePosition: AVCaptureDevice.Position = .front
    @State private var photoCaptureDelegate: PhotoCaptureDelegate?
    @State private var isRealLivePhoto = false
    @StateObject public var coordinator = CameraCoordinator() // Make the coordinator public
    
    public var body: some View {
        VStack {
            if isCameraReady, let previewLayer = previewLayer {
                CameraPreview(previewLayer: previewLayer)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Loading camera...")
                    .onAppear { setupCamera() }
            }
            
            if !isRealLivePhoto {
                Text("Blink or tilt your head at least \(coordinator.requiredMovements) times within 3 seconds to enable the button.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.yellow)
                    .font(.headline)
                    .padding(.top)
            } else {
                Text("You are good to go!")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding(.top)
            }
            
            HStack {
                Button(action: capturePhoto) {
                    Text("Capture Photo")
                        .padding()
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .background(isRealLivePhoto ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(!coordinator.isMovementDetected)
                }
                
                Button(action: toggleCamera) {
                    Image(systemName: "camera.rotate.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onDisappear {
            stopCameraSession()
        }
        .onChange(of: coordinator.isMovementDetected) { newValue in
            isRealLivePhoto = newValue
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: currentDevicePosition
        )
        
        guard let videoDevice = discoverySession.devices.first else {
            print("No camera available.")
            return
        }
        
        currentDevice = videoDevice
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            print("Error setting up video input: \(error)")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(coordinator, queue: DispatchQueue(label: "VideoDataOutputQueue"))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        DispatchQueue.main.async {
            self.previewLayer = previewLayer
            self.isCameraReady = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    private func capturePhoto() {
        guard coordinator.isMovementDetected else {
            print("Cannot capture photo: conditions not met.")
            return
        }
        
        guard let photoOutput = photoOutput else {
            print("Photo output is not available")
            return
        }

        let settings = AVCapturePhotoSettings()
        let delegate = PhotoCaptureDelegate { image in
            if let capturedImage = image {
                onCapture(capturedImage)
            } else {
                print("Failed to capture live photo")
            }
        }
        
        self.photoCaptureDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    private func toggleCamera() {
        guard let session = previewLayer?.session else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.beginConfiguration()
            
            session.inputs.forEach { input in
                session.removeInput(input)
            }
            
            currentDevicePosition = (currentDevicePosition == .front) ? .back : .front
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: currentDevicePosition
            )
            
            guard let newCamera = discoverySession.devices.first else {
                print("No camera available for new position")
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: newCamera)
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                } else {
                    print("Cannot add new camera input")
                }
            } catch {
                print("Error adding new camera input: \(error)")
            }
            
            session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.currentDevice = newCamera
            }
        }
    }
    
    private func stopCameraSession() {
        previewLayer?.session?.stopRunning()
        previewLayer = nil
        photoOutput = nil
        isCameraReady = false
    }
}
