//
//  CustomView.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 7/2/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit
@IBDesignable public class CustomView: UIButton {
    
    @IBInspectable var bottomBorderWidth: CGFloat = 0.0 {
        didSet {
            let border = CALayer()
            border.backgroundColor = layer.borderColor
            border.frame = CGRect(x: 0, y: self.frame.size.height - bottomBorderWidth, width: self.frame.size.width, height: bottomBorderWidth)
            self.layer.addSublayer(border)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
