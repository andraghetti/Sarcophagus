//
//  Button.swift
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

class Button {
    let sprite = SKSpriteNode()
    var textSelected:SKTexture
    var textUnselected:SKTexture
    
    var status: Bool {
        get {
            return self.status
        }
        set (new) {
            self.status = new
            if status {
                sprite.texture = textSelected    //if button is selected
            } else {
                sprite.texture = textUnselected    //if button isn't selected
            }
        }
    }
    
    init(name: String, textSelected: SKTexture, textUnselected: SKTexture, spriteWidth:Int, spriteHeight:Int, position:CGPoint) {
        sprite.texture = textUnselected
        sprite.size = CGSize(width: spriteWidth, height: spriteHeight);
        sprite.position = position;
    
        self.textUnselected = textUnselected
        self.textSelected = textSelected
        self.status = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}