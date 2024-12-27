//
//  LicensePhotoCaptureDelegate.swift
//  VeriEase
//
//  Created by Preeten Dali  on 18/12/24.
//

import UIKit
import AVFoundation

public class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    public init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("Error capturing license photo: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }

        if let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) {
            DispatchQueue.main.async {
                self.completion(image)
            }
        } else {
            DispatchQueue.main.async {
                self.completion(nil)
            }
        }
    }
}
