//
//  CustomTextField.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/14/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    
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
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }

}
