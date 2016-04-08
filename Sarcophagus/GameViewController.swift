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
    
    let floorNode = SCNNode()
    var wallNode = SCNNode()
    var lateralWallRight = SCNNode()
    var lateralWallLeft = SCNNode()
    
    
    var spotLightNode = SCNNode()
    
    
    //HANDLE PAN CAMERA
    var initialPositionCamera = SCNVector3(x: -25, y: 70, z: 1450)
    var translateEnabled = false
    var lastXPos:Float = 0.0
    var lastYPos:Float = 0.0
    var xPos:Float = 0.0
    var yPos:Float = 0.0
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.1
    var widthRatio: Float = 0
    var heightRatio: Float = 0.1
    var fingersNeededToPan = 1 //change this from GUI
    var panAttenuation: Float = 400 //100: very fast ---- 1000 very slow
    let maxWidthRatioRight: Float = 0.2
    let maxWidthRatioLeft: Float = -0.2
    let maxHeightRatioXDown: Float = 0.065
    let maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 1.0  //1.0: very fast ---- 100.0 very slow
    var lastFingersNumber = 0
    let maxPinch = 146.0
    let minPinch = 40.0
    
    //OVERLAY
    var colorPanelScene = SKScene()
    var pickedColor: UIColor = UIColor.whiteColor()
    var NodesToColors = [SKSpriteNode: UIColor]()
    var didPickColor = false
    var OverlayBackground: SKSpriteNode = SKSpriteNode()
    
    func setColors() {
        //Color Setup
        let ColorWhite = colorPanelScene.childNodeWithName("ColorWhite") as! SKSpriteNode
        let ColorRed = colorPanelScene.childNodeWithName("ColorRed") as! SKSpriteNode
        let ColorBrown = colorPanelScene.childNodeWithName("ColorBrown")as! SKSpriteNode
        let ColorDarkBrown = colorPanelScene.childNodeWithName("ColorDarkBrown")as! SKSpriteNode
        
        
        let white = UIColor(red:1, green:0.95, blue:0.71, alpha:1)
        let brown = UIColor(red:0.49, green:0.26, blue:0.17, alpha:1)
        let red = UIColor(red:0.67, green:0.32, blue:0.21, alpha:1)
        let darkBrown = UIColor(red:0.27, green:0.25, blue:0.21, alpha:1)
        
        NodesToColors = [
            ColorWhite: white,
            ColorRed: red,
            ColorBrown: brown,
            ColorDarkBrown: darkBrown
        ]
        
        OverlayBackground = colorPanelScene.childNodeWithName("OverlayBackground")as! SKSpriteNode
    }
    
    func blur(image image: UIImage) -> UIImage {
        let radius: CGFloat = 20;
        let context = CIContext(options: nil);
        let inputImage = CIImage(CGImage: image.CGImage!);
        let filter = CIFilter(name: "CIGaussianBlur");
        filter?.setValue(inputImage, forKey: kCIInputImageKey);
        filter?.setValue("\(radius)", forKey:kCIInputRadiusKey);
        let result = filter?.valueForKey(kCIOutputImageKey) as! CIImage;
        let rect = CGRectMake(radius * 2, radius * 2, image.size.width - radius * 4, image.size.height - radius * 4)
        let cgImage = context.createCGImage(result, fromRect: rect);
        let returnImage = UIImage(CGImage: cgImage);
        
        return returnImage;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/Sarcofago.dae")! //sarcofago.dae
        
        // MARK: Lights
        //create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 1000, z: 1000)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        //MARK: Camera
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 100
        camera.zNear = 10
        camera.zFar = 3000
        
        cameraNode.position = initialPositionCamera
        cameraNode.camera = camera
        cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
        
        
        // cercare su documentazione apple.  deve essere ristretto lo spot della luce.
//        spotLightNode = SCNNode()
//        spotLightNode.light = SCNLight()
//        spotLightNode.light!.type = SCNLightTypeSpot
//        spotLightNode.castsShadow=true
//        let spotLight = spotLightNode.light!
//        //spotLight.color = UIColor.greenColor()
//        spotLight.zNear = 1500
//        spotLight.spotInnerAngle = 10
//        spotLightNode.position = cameraNode.position
//        cameraOrbit.addChildNode(spotLightNode)
        
        //initial camera setup
        self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * lastWidthRatio
        self.cameraOrbit.eulerAngles.x = Float(-M_PI) * lastHeightRatio
        lastXPos = self.cameraNode.position.x
        lastYPos = self.cameraNode.position.y
        
        //MARK: Floor
        let floor = SCNFloor()
        floor.reflectionFalloffEnd = 0
        floor.reflectivity = 0
        
        floorNode.geometry = floor
        floorNode.name = "Floor"
        floorNode.geometry!.firstMaterial!.diffuse.contents = "art.scnassets/floor.png"
        floorNode.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        floorNode.geometry!.firstMaterial!.diffuse.wrapS = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial!.diffuse.wrapT = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial!.diffuse.mipFilter =  SCNFilterMode.Nearest
        floorNode.geometry!.firstMaterial!.doubleSided = false
        floorNode.castsShadow = true
        
        scene.rootNode.addChildNode(floorNode)
        
        //MARK: Walls
        // create the wall geometry
        let wallGeometry = SCNPlane.init(width: 500.0, height: 300.0)
        wallGeometry.firstMaterial!.diffuse.contents = "art.scnassets/background.jpg"
        wallGeometry.firstMaterial!.diffuse.mipFilter =  SCNFilterMode.Nearest
        wallGeometry.firstMaterial!.diffuse.wrapS = SCNWrapMode.Repeat
        wallGeometry.firstMaterial!.diffuse.wrapT = SCNWrapMode.Repeat
        wallGeometry.firstMaterial!.doubleSided = false
        wallGeometry.firstMaterial!.locksAmbientWithDiffuse = true
        
        wallNode = SCNNode.init(geometry: wallGeometry)
        wallNode.name = "FrontWall"
        wallNode.position = SCNVector3Make(0, 120, -300) //this moves all 3 walls
        wallNode.castsShadow = true
        
        //  RIGHT LATERAL WALL
        lateralWallRight = SCNNode.init(geometry: wallGeometry)
        lateralWallRight.name = "lateralWallRight"
        lateralWallRight.position = SCNVector3Make(-300, -20, 150);
        lateralWallRight.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(M_PI/3))
        lateralWallRight.castsShadow = true
        wallNode.addChildNode(lateralWallRight)
        
        // LEFT LATERAL WALL
        lateralWallLeft = SCNNode.init(geometry: wallGeometry)
        lateralWallLeft.name = "lateralWallLeft"
        lateralWallLeft.position = SCNVector3Make(300, -20, 150);
        lateralWallLeft.rotation = SCNVector4(x: 0, y: -1, z: 0, w: Float(M_PI/3))
        lateralWallLeft.castsShadow = true
        wallNode.addChildNode(lateralWallLeft)
        
        //front walls
        scene.rootNode.addChildNode(wallNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false  //not needed
        
        // configure the view
        scnView.backgroundColor = UIColor.grayColor()
        
        
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
        
        setColors()
        
        //let OverlayBackground = colorPanelScene.childNodeWithName("OverlayBackground")as! SKSpriteNode
        
    }
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        
        let numberOfTouches = gestureRecognize.numberOfTouches()
        
        let translation = gestureRecognize.translationInView(gestureRecognize.view!)
        
        
        if (numberOfTouches==fingersNeededToPan) {
            
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
            lastFingersNumber = fingersNeededToPan
            
            //TRANSLATION pan
        } else if numberOfTouches == (fingersNeededToPan+1) {
            
            let velocity = gestureRecognize.velocityInView(gestureRecognize.view!)
            
            //print("translation: \(-velocity) y: \(velocity) ")
            
            self.cameraOrbit.position.x += Float(-velocity.x)/panAttenuation
            self.cameraOrbit.position.y += Float(velocity.y)/panAttenuation
            
        }
        
        if (lastFingersNumber == fingersNeededToPan && numberOfTouches != fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            
        }
        
        if (gestureRecognize.state == .Ended) {
            if (lastFingersNumber==fingersNeededToPan) {
                lastWidthRatio = widthRatio
                lastHeightRatio = heightRatio
                //print("lastHeight: \(round(lastHeightRatio*100))")
                //print("lastWidth: \(round(lastWidthRatio*100))")
                
            }
            
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
    }
    
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let pinchVelocity = Double.init(gestureRecognize.velocity)
        //print("PinchVelocity \(pinchVelocity)")
        
        camera.orthographicScale -= (pinchVelocity/pinchAttenuation)
        
        if camera.orthographicScale <= minPinch {
            camera.orthographicScale = minPinch
        }
        
        if camera.orthographicScale >= maxPinch {
            camera.orthographicScale = maxPinch
        }
        
        if (gestureRecognize.state == .Ended) {
            print("\nPinch: \(round(camera.orthographicScale))\n")
        }
        
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        print("---------------TAP-----------------")
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        let touchedPointInScene = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(touchedPointInScene, options: nil)
        
        let OverlayView = colorPanelScene.view! as SKView
        let touchedPointInOverlay = gestureRecognize.locationInView(OverlayView)
        
        
        // if button color are touched
        if OverlayBackground.containsPoint(touchedPointInOverlay) {
            print("OVERLAY: tap in \(touchedPointInOverlay)")
            
            for (node, color) in NodesToColors {
                // Check if the location of the touch is within the button's bounds
                if node.containsPoint(touchedPointInOverlay) {
                    print("\(node.name!) -> color picked \(color.description)")
                    pickedColor = color
                    didPickColor = true
                }
            }
        } else {//if sarcophagus is touched
            
            // check that we clicked on at least one object
            if hitResults.count > 0 && didPickColor {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                print("OBJECT tap: \(result.node.name!)")
                
                //Exclude floor and wall from color
                if result.node! != floorNode && result.node! != wallNode && result.node! != lateralWallRight && result.node! != lateralWallLeft {
                    // get its material
                    let material = result.node!.geometry!.firstMaterial!
                    print("material: \(material.name!)")
                    
                    // begin coloration
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    // on completion - keep color
                    SCNTransaction.setCompletionBlock {
                        SCNTransaction.begin()
                        SCNTransaction.setAnimationDuration(0.3)
                        
                        material.diffuse.contents = self.pickedColor
                        
                        SCNTransaction.commit()
                    }
                    
                    SCNTransaction.commit()
                    
                    material.diffuse.contents = pickedColor
                }
            }
        }
        print("-----------------------------------\n")
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