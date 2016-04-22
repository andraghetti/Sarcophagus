//
//  GameViewController.swift
//  Sarcophagus
//
//  Created by Andraghetti on 24/02/16.
//  Copyright (c) 2016 Lorenzo Andraghetti. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {
    
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    var spotLightNode = SCNNode()
    
    var decorationNode = SCNNode()
    var backgroundNode = SCNNode()
    
    let sceneRatio:Float = 1 //try to mantain to 100. It's not set in all var
    
    var lastFingersNumber = 0
    
    //HANDLE PAN CAMERA
    var initialPositionCamera = SCNVector3(x: -0.25, y: 0.7, z: 5)
    let maxPanY:Float = 1.6
    let minPanY:Float = 0.0
    let maxPanX:Float = 1.6
    let minPanX:Float = -1.6
    var fingersToPan = 1 //change this from GUI
    var panAttenuation: Float = 38000 //100: very fast ---- 1000 very slow
    
    let initialWidthRatio: Float = 0
    let initialHeightRatio: Float = 0.1
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0
    var widthRatio: Float = 0
    var heightRatio: Float = 0.1
    
    let maxWidthRatioRight: Float = 0.2
    let maxWidthRatioLeft: Float = -0.2
    let maxHeightRatioXDown: Float = 0.065
    let maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 100.0  //10.0: very fast ---- 1000.0 very slow
    let initialPinchScale: Double = 1.1
    let minPinchVelocity = -15.0
    let maxPinchVelocity = 15.0
    let maxPinch = 1.4
    let minPinch = 0.4
    
    //OVERLAY
    var colorPanelScene = SKScene()
    var pickedColor: UIColor = UIColor.whiteColor()
    var NodesToColors = [SKSpriteNode: UIColor]()
    var didPickColor = false
    var didPickFunction = false
    var ColorWhiteButton: SKSpriteNode = SKSpriteNode()
    var ColorRedButton: SKSpriteNode = SKSpriteNode()
    var ColorBrownButton: SKSpriteNode = SKSpriteNode()
    var ColorDarkBrownButton: SKSpriteNode = SKSpriteNode()
    var OverlayBackground: SKSpriteNode = SKSpriteNode()
    var ChangeModeButton: SKSpriteNode = SKSpriteNode()
    var ResetCameraButton: SKSpriteNode = SKSpriteNode()
    var ResetFigureButton: SKSpriteNode = SKSpriteNode()
    var FunctionAtlas: SKTextureAtlas = SKTextureAtlas()
    var ColorAtlas: SKTextureAtlas = SKTextureAtlas()
    
    
    var screenOrientation: UIInterfaceOrientation {
        get {
            return UIApplication.sharedApplication().statusBarOrientation
        }
    }
    var screenWidth: CGFloat {
        get {
            if UIInterfaceOrientationIsPortrait(screenOrientation) {
                return UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale
            } else {
                return UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale
            }
        }
    }
    var screenHeight: CGFloat {
        get {
            if UIInterfaceOrientationIsPortrait(screenOrientation) {
                return UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale
            } else {
                return UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale
            }
        }
    }
    
    
    func setPanel() {
        //Color Setup
        ColorWhiteButton = colorPanelScene.childNodeWithName("ColorWhite") as! SKSpriteNode
        ColorRedButton = colorPanelScene.childNodeWithName("ColorRed") as! SKSpriteNode
        ColorBrownButton = colorPanelScene.childNodeWithName("ColorBrown")as! SKSpriteNode
        ColorDarkBrownButton = colorPanelScene.childNodeWithName("ColorDarkBrown")as! SKSpriteNode
        
        OverlayBackground = colorPanelScene.childNodeWithName("OverlayBackground") as! SKSpriteNode
        ChangeModeButton = colorPanelScene.childNodeWithName("ChangeMode") as! SKSpriteNode
        ResetCameraButton = colorPanelScene.childNodeWithName("ResetCamera") as! SKSpriteNode
        ResetFigureButton = colorPanelScene.childNodeWithName("ResetFigure") as! SKSpriteNode
        
        
        
        let white = UIColor(red:0.96, green:0.93, blue:0.71, alpha:1.00)
        let red = UIColor(red:0.64, green:0.29, blue:0.18, alpha:1.00)
        let brown = UIColor(red:0.45, green:0.28, blue:0.22, alpha:1.00)
        let darkBrown = UIColor(red:0.34, green:0.26, blue:0.23, alpha:1.00)
        
        NodesToColors = [
            ColorWhiteButton: white,
            ColorRedButton: red,
            ColorBrownButton: brown,
            ColorDarkBrownButton: darkBrown
        ]
        
        
        //        let buttons = [ColorWhiteButton, ColorRedButton, ColorBrownButton, ColorDarkBrownButton, ChangeModeButton, ResetCameraButton,ResetFigureButton]
        //
        //        for button in buttons {
        //            button.size.height = screenWidth/11
        //            button.size.width = screenWidth/11
        //        }
        
        FunctionAtlas = SKTextureAtlas(named: "FunctionAtlas")
        ColorAtlas = SKTextureAtlas(named: "ColorAtlas")
        
        ChangeModeButton.texture = fingersToPan == 1 ? FunctionAtlas.textureNamed("OneFinger") : FunctionAtlas.textureNamed("TwoFinger")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/sarcofago.dae")!
        
        // MARK: Lights
        //create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10*sceneRatio, z: 10*sceneRatio)
        lightNode.light?.castsShadow = true
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        ambientLightNode.light?.castsShadow = true
        scene.rootNode.addChildNode(ambientLightNode)


        
        //MARK: Camera
        initialPositionCamera = SCNVector3(x: -0.35*sceneRatio, y: 0.7*sceneRatio, z: 10*sceneRatio)
        camera.usesOrthographicProjection = true
        camera.orthographicScale = Double(sceneRatio)
        camera.zNear = 0.1*Double(sceneRatio)
        camera.zFar = 30*Double(sceneRatio)
        
        cameraNode.position = initialPositionCamera
        cameraNode.camera = camera
        cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
        
        //initial camera setup
        self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * initialWidthRatio
        self.cameraOrbit.eulerAngles.x = Float(-M_PI) * initialHeightRatio
        self.cameraNode.camera?.orthographicScale = initialPinchScale
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        decorationNode = scene.rootNode.childNodeWithName("decorazioni", recursively: true)!
        backgroundNode = scene.rootNode.childNodeWithName("background", recursively: true)!
        
        //MARK: Gesture Recognizer in SceneView
        
        // add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(GameViewController.handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)
        
        //MARK: OverLay
        
        colorPanelScene = SKScene(fileNamed: "art.scnassets/ColorPanelScene")!
        scnView.overlaySKScene = colorPanelScene
        scnView.overlaySKScene!.userInteractionEnabled = true;
        
        didPickColor = false
        
        setPanel()
        
    }
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        
        let numberOfTouches = gestureRecognize.numberOfTouches()
        
        if(gestureRecognize.state == .Began) {
            lastFingersNumber = numberOfTouches
        }
        
        //ROTATION pan
        if (lastFingersNumber==fingersToPan) {
            
            let translation = gestureRecognize.translationInView(gestureRecognize.view!)
            
            widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width) + lastWidthRatio
            heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) + lastHeightRatio
            
            //  HEIGHT constraints
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            //  WIDTH constraints
            if(widthRatio >= maxWidthRatioRight) {
                widthRatio = maxWidthRatioRight
            }
            if(widthRatio <= maxWidthRatioLeft) {
                widthRatio = maxWidthRatioLeft
            }
            
            self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * widthRatio
            self.cameraOrbit.eulerAngles.x = Float(-M_PI) * heightRatio
            
            //TRANSLATION pan
        } else if lastFingersNumber == (fingersToPan+1) {
            
            let velocity = gestureRecognize.velocityInView(gestureRecognize.view!)
            
            //print("translation: \(-velocity) y: \(velocity) ")
            
            self.cameraNode.position.x += Float(-velocity.x)/panAttenuation
            self.cameraNode.position.y += Float(velocity.y)/panAttenuation
            
            //  X  Constrains
            if (self.cameraNode.position.x >= maxPanX) {
                self.cameraNode.position.x = maxPanX
            }
            if (self.cameraNode.position.x <= minPanX) {
                self.cameraNode.position.x = minPanX
            }
            //  Y  Constraints
            if (self.cameraNode.position.y >= maxPanY) {
                self.cameraNode.position.y = maxPanY
            }
            if (self.cameraNode.position.y <= minPanY) {
                self.cameraNode.position.y = minPanY
            }
        }
        
        if (gestureRecognize.state == .Ended) {
            if (lastFingersNumber==fingersToPan) {
                lastWidthRatio = widthRatio
                lastHeightRatio = heightRatio
            }
            
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
            //          print("X: \(self.cameraNode.position.x), Y: \(self.cameraNode.position.y)\n")
        }
    }
    
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let pinchVelocity = Double.init(gestureRecognize.velocity)
        //        print("PinchVelocity \(pinchVelocity)")
        
        let camera = cameraNode.camera!
        
        if (pinchVelocity>minPinchVelocity && pinchVelocity<maxPinchVelocity) {
            camera.orthographicScale -= (pinchVelocity/pinchAttenuation)
        }
        
        if camera.orthographicScale <= minPinch {
            camera.orthographicScale = minPinch
        }
        
        if camera.orthographicScale >= maxPinch {
            camera.orthographicScale = maxPinch
        }
        
        if (gestureRecognize.state == .Ended) {
            print("\nPinch: \(round(camera.orthographicScale*100))\n")
            
        }
        
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        print("---------------TAP-----------------")
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        let touchedPointInScene = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(touchedPointInScene, options: nil)
        
        let touchedPointInOverlay = colorPanelScene.convertPointFromView(touchedPointInScene)
        
        
        
        // if buttons are touched
        if OverlayBackground.containsPoint(touchedPointInOverlay) {
            
            didPickFunction = false
            
            print("OVERLAY: tap in \(touchedPointInOverlay)")
            
            if (ChangeModeButton.containsPoint(touchedPointInOverlay)) {
                print("Change mode: \(fingersToPan)")
                
                fingersToPan = fingersToPan == 2 ? 1: 2
                
                if (fingersToPan==1) {
                    let texture = FunctionAtlas.textureNamed("OneFinger")
                    ChangeModeButton.texture = texture
                }
                
                if (fingersToPan==2) {
                    let texture = FunctionAtlas.textureNamed("TwoFinger")
                    ChangeModeButton.texture = texture
                }
                
                didPickFunction = true
                
            }
            
            if (ResetCameraButton.containsPoint(touchedPointInOverlay)) {
                
                let moveTo = SCNAction.moveTo(initialPositionCamera, duration: 2);
                moveTo.timingMode = SCNActionTimingMode.EaseInEaseOut;
                cameraNode.runAction(moveTo)
                
                let initialAngleY = Float(-2 * M_PI) * self.initialWidthRatio
                let initialAngleX = Float(-M_PI) * self.initialHeightRatio
                let scale = self.cameraNode.camera?.orthographicScale
                
                
                // begin coloration
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(2)
                
                
                // on completion - select
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(2)
                    
                    self.cameraOrbit.eulerAngles.y = initialAngleY
                    self.cameraOrbit.eulerAngles.x = initialAngleX
                    self.cameraNode.camera?.orthographicScale = self.initialPinchScale
                   
                    SCNTransaction.commit()
                    
                }
                SCNTransaction.commit()
                
                self.lastWidthRatio = self.initialWidthRatio
                self.lastHeightRatio = self.initialHeightRatio
                
                print("Reset Camera Position: \(cameraNode.position), Scale: \(scale!)")
                
                
                refresh()
                
                didPickFunction = true
                
            }
            
            if (ResetFigureButton.containsPoint(touchedPointInOverlay)) {
                print("Reset Figure. TODO")
                didPickFunction = true
                
            }
            
            if !didPickFunction {
                for (node, color) in NodesToColors {
                    
                    let nodeName = node.name!  //e.g. ColorWhite
                    let index5 = nodeName.startIndex.advancedBy(5)
                    let colorName = nodeName.substringFromIndex(index5)  //ColoreWhite - Color = White
                    
                    // Check if the location of the touch is within the button's bounds
                    if node.containsPoint(touchedPointInOverlay) {
                        print("\(node.name!) -> color picked \(color.description)")
                        pickedColor = color
                        didPickColor = true
                        
                        node.texture = self.ColorAtlas.textureNamed("\(colorName)Selected")
                        
                    } else {
                        node.texture = self.ColorAtlas.textureNamed("\(colorName)Unselected")
                    }
                }
            }
            refresh()
        } else {//if sarcophagus is touched
            
            // check that we clicked on at least one object
            if hitResults.count > 0 && didPickColor {
                // retrieved the first clicked object
                var result: SCNHitTestResult! = hitResults[0]
                
                //Exclude background from color
                if result.node != backgroundNode{
                    let result2: SCNHitTestResult! = hitResults[1]
                    
                    print("OBJECT tap: \(result.node.name!)")
                    print("OBJECT2 tap: \(result2.node.name!)")
                    
                    if result.node == decorationNode {
                        result = result2
                    }
                
                
                    // get its material
                    let material = result.node.geometry!.firstMaterial!
                    print("material: \(material.name!)")
                                        
                    material.multiply.contents = pickedColor
                }
            }
        }
        print("-----------------------------------\n")
    }
    
    func refresh() {
        
        //to refresh the panel
        let current = self.cameraNode.position.x
        self.cameraNode.position.x = 0
        self.cameraNode.position.x = current
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}