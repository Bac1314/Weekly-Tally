//
//  CustomProgressView.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/14/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

@IBDesignable
class CustomProgressView: UIProgressView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
//     @IBInspectable public var borderColor:UIColor? {
//         didSet {
//             layer.borderColor = borderColor?.cgColor
//         }
//    }
//    @IBInspectable public var borderWidth:CGFloat = 0
//        {
//         didSet {
//             layer.borderWidth = borderWidth
//         }
//    }
    
    @IBInspectable public var cornerRadius:CGFloat {
         get {
             return layer.cornerRadius
         }
         set {
             layer.cornerRadius = newValue
             layer.masksToBounds = newValue > 0
         }
    }

    
//    @IBInspectable var rotation: Int {
//        get {
//            return 0
//        } set {
//            let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
//            self.transform = CGAffineTransform(rotationAngle: radians)
//        }
//    }
//    
//    @IBInspectable var rotation: Int = 0 {
//        didSet {
//            rotateButton(rotation: rotation)
//        }
//    }
    
//    func rotateButton(rotation: Int)  {
////        self.transform = CGAffineTransform(rotationAngle: CGFloat(.pi + rotation))
//        self.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
//    }
    
//    @IBInspectable public var rotateAngle:CATransform3D{
//        get{
//            return layer.transform
//        }set{
//            layer.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//        }
//    }

}

