//
//  SignInButton.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

@IBDesignable class SignInButton: UIButton {
    
    @IBInspectable var buttonColor = UIColor.yellow {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(ovalIn: rect)
        buttonColor.setFill()
        path.fill()
    }
}
