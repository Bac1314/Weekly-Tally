//
//  CustomView.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/13/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//
import UIKit

@IBDesignable
class CustomView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
     @IBInspectable public var borderColor:UIColor? {
         didSet {
             layer.borderColor = borderColor?.cgColor
         }
    }
    @IBInspectable public var borderWidth:CGFloat = 0
        {
         didSet {
             layer.borderWidth = borderWidth
         }
    }
    @IBInspectable public var cornerRadius:CGFloat {
         get {
             return layer.cornerRadius
         }
         set {
             layer.cornerRadius = newValue
             layer.masksToBounds = newValue > 0
         }
    }



}
