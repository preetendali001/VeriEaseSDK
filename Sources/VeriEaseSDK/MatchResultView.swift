//
//  MatchResultView.swift
//  VeriEase
//
//  Created by Preeten Dali on 12/12/24.
//

import SwiftUI
import Vision

struct MatchResultView: View {
    
    var scannedLicense: UIImage?
    var livePhoto: UIImage?
    var onBack: () -> Void
    
    @State private var matchResult: String = "Processing..."
    @State private var isProcessing: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                resultImageSection(title: "Scanned License", image: scannedLicense)
                resultImageSection(title: "Live Photo", image: livePhoto)
            }
            if isProcessing {
                ProgressView("Processing...")
                    .padding()
            } else {
                resultText
            }
            backButton
        }
        .onAppear(perform: processMatching)
        .padding()
    }
}

extension MatchResultView {
    
    private func resultImageSection(title: String, image: UIImage?) -> some View {
        VStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .border(Color.gray, width: 0.5)
                Text(title)
                    .font(.subheadline)
            } else {
                Text("\(title) Missing")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var resultText: some View {
        Text(matchResult)
            .font(.headline)
            .foregroundColor(matchResult.contains("Faces Match!") ? .green : .red)
            .padding()
    }
    
    private var backButton: some View {
        Button(action: onBack) {
            Text("Back")
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
    
    private func processMatching() {
        guard let licenseImage = scannedLicense, let liveImage = livePhoto else {
            setProcessingResult(result: "Images are missing.")
            return
        }
        
        let visionService = VisionService()
        let glassDetector = GlassesDetector()
        
        detectAndAlignFace(service: visionService, image: licenseImage) { licenseFace in
            guard let licenseFace = licenseFace else {
                setProcessingResult(result: "No face detected in license image.")
                return
            }
            
            detectAndAlignFace(service: visionService, image: liveImage) { liveFace in
                guard let liveFace = liveFace else {
                    setProcessingResult(result: "No face detected in live photo.")
                    return
                }
                let isMatch = visionService.compareFaces(licenseFace: licenseFace, liveFace: liveFace)
                
                if isMatch {
                    setProcessingResult(result: "Faces Match!")
                } else {
                    let licenseGlassesResult = glassDetector.detectGlasses(face: licenseFace)
                    let liveGlassesResult = glassDetector.detectGlasses(face: liveFace)
                    
                    if !licenseGlassesResult.hasGlasses && liveGlassesResult.hasGlasses {
                        setProcessingResult(result: "Faces Do Not Match! Please remove glasses and try again.")
                    } else {
                        setProcessingResult(result: "Faces Do Not Match!")
                    }
                }
            }
        }
    }

    private func detectAndAlignFace(service: VisionService, image: UIImage, completion: @escaping (VNFaceObservation?) -> Void) {
        service.detectFaceLandmarks(image: image) { face in
            guard let face = face else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let cgImage = image.cgImage, let alignedFace = service.alignFace(faceObservation: face, image: cgImage) {
                DispatchQueue.main.async {
                    completion(alignedFace)
                }
            } else {
                DispatchQueue.main.async {
                    completion(face)
                }
            }
        }
    }
    
    private func setProcessingResult(result: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            matchResult = result
            isProcessing = false
        }
    }
}
