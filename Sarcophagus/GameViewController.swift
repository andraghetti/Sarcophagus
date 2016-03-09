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

class GameViewController: UIViewController {
    
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    
    let floorNode = SCNNode()
    var wallNode = SCNNode()
    
    //var spotLightNode = SCNNode()
    
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.1
    var widthRatio: Float = 0
    var heightRatio: Float = 0.1
    var fingersNeededToPan = 1 //change this from GUI
    let maxWidthRatioRight: Float = 0.2
    let maxWidthRatioLeft: Float = -0.2
    let maxHeightRatioXDown: Float = 0.065
    let maxHeightRatioXUp: Float = 0.4
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 1.0  //1.0: very fast ---- 100.0 very slow
    var lastFingersNumber = 0
    let maxPinch = 146.0
    let minPinch = 40.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/sarcophagus.scn")!
        
        // create and add a light to the scene
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
        
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 100
        camera.zNear = 1
        camera.zFar = 4000
        
        cameraNode.position = SCNVector3(x: 0, y: 50, z: 1450)
        cameraNode.camera = camera
        cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
        
        //initial camera setup
        self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * lastWidthRatio
        self.cameraOrbit.eulerAngles.x = Float(-M_PI) * lastHeightRatio
        
        //FLOOR
        let floor = SCNFloor()
        floor.reflectionFalloffEnd = 0;
        floor.reflectivity = 0;
        
        floorNode.geometry = floor;
        floorNode.geometry!.firstMaterial!.diffuse.contents = "art.scnassets/floor.png";
        floorNode.geometry!.firstMaterial!.locksAmbientWithDiffuse = true
        floorNode.geometry!.firstMaterial!.diffuse.wrapS = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial!.diffuse.wrapT = SCNWrapMode.Repeat
        floorNode.geometry!.firstMaterial!.diffuse.mipFilter =  SCNFilterMode.Nearest
        floorNode.geometry!.firstMaterial!.doubleSided = false;
        
        scene.rootNode.addChildNode(floorNode)
        
        //WALL
        // create the wall geometry
        let wallGeometry = SCNPlane.init(width: 500.0, height: 300.0)
        wallGeometry.firstMaterial!.diffuse.contents = "art.scnassets/background.jpg";
        floorNode.geometry!.firstMaterial!.diffuse.mipFilter =  SCNFilterMode.Nearest
        wallGeometry.firstMaterial!.diffuse.wrapS = SCNWrapMode.Repeat;
        wallGeometry.firstMaterial!.diffuse.wrapT = SCNWrapMode.Repeat;
        wallGeometry.firstMaterial!.doubleSided = false;
        wallGeometry.firstMaterial!.locksAmbientWithDiffuse = true;
        
        wallNode = SCNNode.init(geometry: wallGeometry)
        wallNode.position = SCNVector3Make(0, 120, -300); //this moves all 3 walls
        wallNode.castsShadow = false
        
        //  RIGHT LATERAL WALL
        let lateralWallRight = SCNNode.init(geometry: wallGeometry)
        lateralWallRight.position = SCNVector3Make(-300, -20, 150);
        lateralWallRight.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(M_PI/3))
        lateralWallRight.castsShadow = false
        wallNode.addChildNode(lateralWallRight)
        
        // LEFT LATERAL WALL
        let lateralWallLeft = SCNNode.init(geometry: wallGeometry)
        lateralWallLeft.position = SCNVector3Make(300, -20, 150);
        lateralWallLeft.rotation = SCNVector4(x: 0, y: -1, z: 0, w: Float(M_PI/3))
        lateralWallLeft.castsShadow = false
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
        
        // add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        scnView.addGestureRecognizer(panGesture)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        scnView.addGestureRecognizer(tapGesture)
        
        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        scnView.addGestureRecognizer(pinchGesture)
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
            
//            print("Height: \(round(heightRatio*100))")
//            print("Width: \(round(widthRatio*100))")
            
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        //lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .Ended/* && lastFingersNumber==fingersNeededToPan*/) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            //print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
            print("lastHeight: \(round(lastHeightRatio*100))")
            print("lastWidth: \(round(lastWidthRatio*100))")
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
            print("\nPinch: \(camera.orthographicScale)\n")
        }
        
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            //Exclude floor and wall from color
            if result.node! != floorNode && result.node! != wallNode {
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // begin coloration
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                let pickedColor = UIColor.greenColor()
                
                // on completion - keep color
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.diffuse.contents = pickedColor
                    
                    SCNTransaction.commit()
                }
                
                material.diffuse.contents = pickedColor
                
                SCNTransaction.commit()
            }
        }
    }

    
    override func shouldAutorotate() -> Bool {
        return true
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