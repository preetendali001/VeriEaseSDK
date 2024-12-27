//
//  CameraPreview.swift
//  VeriEase
//
//  Created by Preeten Dali  on 13/12/24.
//

import SwiftUI
import AVFoundation

public struct CameraPreview: UIViewControllerRepresentable { // Make it public
    public let previewLayer: AVCaptureVideoPreviewLayer // Make property public

    // Public initializer to allow external initialization
    public init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
    }

    public func makeUIViewController(context: Context) -> UIViewController { // Make public
        let controller = UIViewController()
        controller.view.layer.addSublayer(previewLayer)
        previewLayer.frame = controller.view.bounds
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) { // Make public
        previewLayer.frame = uiViewController.view.bounds
    }
}

