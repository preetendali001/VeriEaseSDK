//
//  CameraPreview.swift
//  VeriEase
//
//  Created by Preeten Dali  on 13/12/24.
//

import SwiftUI
import AVFoundation

public struct CameraPreview: UIViewControllerRepresentable {
    public let previewLayer: AVCaptureVideoPreviewLayer

    public init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.layer.addSublayer(previewLayer)
        previewLayer.frame = controller.view.bounds
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        previewLayer.frame = uiViewController.view.bounds
    }
}

