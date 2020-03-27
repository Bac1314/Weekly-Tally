//
//  CustomShare.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/22/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit
import AVFoundation

class CustomShare  {
    
    var imageOrientation: AVCaptureVideoOrientation?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?

    init() {
    }
    
    // Create ImageView out of UIView
    public func viewToImage(view: UIView) -> UIImage {

        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
    
    // Generate a QR code
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    // Scan QR code
    func scanQRcode() {

        
    }
    
    

}
