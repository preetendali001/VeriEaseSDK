//
//  LicenseScannerView.swift
//  VeriEase
//
//  Created by Preeten Dali on 12/12/24.
//

import SwiftUI
import AVFoundation

public struct LicenseScannerView: View {
    
    public var onScanned: (UIImage) -> Void

    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var captureSession: AVCaptureSession?
    @State private var photoOutput: AVCapturePhotoOutput?
    @State private var isCameraReady = false
    @State private var photoCaptureDelegate: PhotoCaptureDelegate?

    public init(onScanned: @escaping (UIImage) -> Void) {
        self.onScanned = onScanned
    }

    public var body: some View {
        VStack {
            if isCameraReady, let previewLayer = previewLayer {
                CameraPreview(previewLayer: previewLayer)
            } else {
                Text("Loading camera...")
                    .onAppear { setupCamera() }
            }

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
