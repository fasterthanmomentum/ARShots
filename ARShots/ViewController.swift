//
//  ViewController.swift
//  ARShots
//
//  Created by JOY BEST on 8/24/19.
//  Copyright © 2019 JOY BEST. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var hoopAdded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/hoop.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Set the scene to the view
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        
        // Run the view's session
        sceneView.session.run(configuration)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if !hoopAdded {
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types:
        [.existingPlaneUsingExtent])
        if let result = hitTestResult.first {
            addHoop(result: result)
            hoopAdded = true
        }
        } else {
            createBasketball()
        }
        }
    func addHoop(result: ARHitTestResult) {
        let hoopScene = SCNScene(named: "art.scnassets/hoop.scn")
        guard let hoopNode = hoopScene?.rootNode.childNode(withName:
            "Hoop", recursively: false) else {
                return
        }
        
        let planePosition = result.worldTransform.columns.3
        hoopNode.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z)
       
        hoopNode.physicsBody = SCNPhysicsBody(type: .static, shape:
            SCNPhysicsShape(node: hoopNode, options:
                [SCNPhysicsShape.Option.type :
                SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        
        //sceneView.scene.rootNode.addChildNode(basketNode)
     sceneView.scene.rootNode.addChildNode(hoopNode)
        
    }
    
        
    func createBasketball() {
      
        guard let currentFrame = sceneView.session.currentFrame else { return}
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        ball.transform = cameraTransform
        
        
        //let physicsBody = SCNPhysicsBody(type: .dynamic, shape:n
         //   SCNPhysicsShape(node: ball))
        //ball.physicsBody = physicsBody
    
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape:
            SCNPhysicsShape(node: ball, options:
                [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        ball.physicsBody = physicsBody
       
        let power = Float(10.0)
        let force = SCNVector3(-cameraTransform.m31*power,
        -cameraTransform.m32*power, -cameraTransform.m33*power)
        ball.physicsBody?.applyForce(force, asImpulse: true)
       sceneView.scene.rootNode.addChildNode(ball)
        
    }

    
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        let geometry = SCNPlane(width:
            CGFloat(planeAnchor.extent.x), height:
            CGFloat(planeAnchor.extent.z))
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.25
        return node
    }
    //balls
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node:
        SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let floor = createFloor(planeAnchor: planeAnchor)
        node.addChildNode(floor)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node:
        SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
        let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else 
        {return}
        planeNode.position = SCNVector3(planeAnchor.center.x, 0,
        planeAnchor.center.z)
        plane.width = CGFloat(planeAnchor.extent.y)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
        
        
    
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
