//
//  CameraPreview.swift
//  VeriEase
//
//  Created by Preeten Dali  on 13/12/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewControllerRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.layer.addSublayer(previewLayer)
        previewLayer.frame = controller.view.bounds
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
