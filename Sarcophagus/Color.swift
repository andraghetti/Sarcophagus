//
//  Color.swift
//  Sarcophagus
//
//  Created by Andraghetti on 06/04/16.
//  Copyright © 2016 Lorenzo Andraghetti. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class Color {
    
    var name: String {
        get {
            let colorRef: CGColorRef = self.color.CGColor;
            let colorString: NSString = CIColor.init(CGColor: colorRef).stringRepresentation
            return "Color: \(self.name) " + "(\(colorString as String))"
        }
        set (newName) {
            self.name=newName
        }
    }
    
    var color: UIColor {
        get {
            return self.color
        }
        set (color) {
            self.color = color
        }
    }
    
    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
    
    convenience init() {
        self.init(name: "[Unnamed]", color: UIColor(red:1, green:0.95, blue:0.71, alpha:1))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        fatalError("init(colorLiteralRed:green:blue:alpha:) has not been implemented")
    }
}
