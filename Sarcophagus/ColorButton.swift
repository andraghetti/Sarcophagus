//
//  ColorButton.swift
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

class ColorButton: Button {
    
    var colorButton: Color
    
    init(name: String, textSelected: SKTexture, textUnselected: SKTexture, spriteWidth:Int, spriteHeight:Int, position:CGPoint, color: Color) {
        self.colorButton = color
        super.init(name: name, textSelected: textSelected, textUnselected: textUnselected, spriteWidth: spriteWidth, spriteHeight: spriteHeight, position: position)
            }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}