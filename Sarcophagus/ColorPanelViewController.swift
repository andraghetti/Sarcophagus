//
//  ColorPanel.swift
//  Sarcophagus
//
//  Created by Andraghetti on 05/04/16.
//  Copyright © 2016 Lorenzo Andraghetti. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class ColorPanelViewController {
    
    var buttons: Button
    var panelView: UIVisualEffectView
    
    init(buttons: Button) {
        self.buttons = buttons
        
        var screenOrientation: UIInterfaceOrientation {
            get {
                return UIApplication.sharedApplication().statusBarOrientation
            }
        }
        var screenWidth: CGFloat {
            get {
                if UIInterfaceOrientationIsPortrait(screenOrientation) {
                    return UIScreen.mainScreen().bounds.size.width
                } else {
                    return UIScreen.mainScreen().bounds.size.height
                }
            }
        }
        var screenHeight: CGFloat {
            get {
                if UIInterfaceOrientationIsPortrait(screenOrientation) {
                    return UIScreen.mainScreen().bounds.size.height
                } else {
                    return UIScreen.mainScreen().bounds.size.width
                }
            }
        }

        
        panelView = UIVisualEffectView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight/10))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



