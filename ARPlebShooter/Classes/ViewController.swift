//
//  ViewController.swift
//  ARPlebShooter
//
//  Created by Brent Piephoff on 7/12/17.
//  Copyright © 2017 Brent Piephoff. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var leftDirectionIndicator: UILabel!
    @IBOutlet weak var rightDirectionIndicator: UILabel!
    
    var fireParticleNode : SCNNode?
    
    var playerNode : SCNNode?
    let gameHelper = GameHelper.sharedInstance
    
    private var userScore: Int = 0 {
        didSet {
            // ensure UI update runs on main thread
            DispatchQueue.main.async {
                self.statusLabel.text = String(self.userScore)
            }
        }
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new empty scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let skScene = SKScene(size: CGSize(width: 500, height: 100))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureSession()
        self.beginPlaying()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func configureSession() {
        if ARWorldTrackingSessionConfiguration.isSupported { // checks if user's device supports the more precise ARWorldTrackingSessionConfiguration
            // equivalent to `if utsname().hasAtLeastA9()`
            // Create a session configuration
            let configuration = ARWorldTrackingSessionConfiguration()
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.delegate = self
            sceneView.session.run(configuration)
        } else {
            // slightly less immersive AR experience due to lower end processor
            let configuration = ARSessionConfiguration()
            // Run the view's session
            sceneView.session.run(configuration)
        }
    }

    // MARK: - Actions
    @IBAction func didTapScreen(_ sender: UITapGestureRecognizer) { // fire bullet in direction camera is facing
        switch gameHelper.state {
        case .Playing:
            self.shootBullet()
        case .TapToPlay:
            self.beginPlaying()
        }
    }
    
    // Mark: - Direction Indicators
    
    func displayDirectionIndicatorsIfAppropriate() {
        if let target = gameHelper.liveTargets.first
        {
            let (_, targetPosition) = self.getTargetVector(for: target)
            let (userDirection, _) = self.getUserVector()

            
            if(fabs(targetPosition.x) > 0.6 && targetPosition.x > userDirection.x)
            {
                //show right indicator
                DispatchQueue.main.async {
                    if self.rightDirectionIndicator.isHidden {
                        self.rightDirectionIndicator.isHidden = false
                        self.leftDirectionIndicator.isHidden = true

                        self.animateDirectionIndicators()
                    }
                }
                
            }else if(fabs(targetPosition.x) > 0.6 && targetPosition.x < userDirection.x) {
                //show left indicator
                DispatchQueue.main.async {
                    if self.leftDirectionIndicator.isHidden {
                        self.leftDirectionIndicator.isHidden = false
                        self.rightDirectionIndicator.isHidden = true

                        self.animateDirectionIndicators()
                    }
                }
            }else{
                //hide direction indicators
                self.hideDirectionIndicators()
            }
        }
    }
    
    func hideDirectionIndicators() {
        DispatchQueue.main.async {
            self.endDirectionIndicatorAnimations()
            
            self.rightDirectionIndicator.isHidden = true
            self.leftDirectionIndicator.isHidden = true
        }
    }
    
    func animateDirectionIndicators() {
        DispatchQueue.main.async {
            self.rightDirectionIndicator.alpha = 0
            self.leftDirectionIndicator.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.05, options:[.repeat,.autoreverse],
                           animations:{
                            self.rightDirectionIndicator.alpha = 1.0
                            self.leftDirectionIndicator.alpha = 1.0
                            
            }, completion: nil)
        }
    }
    
    func endDirectionIndicatorAnimations() {
        DispatchQueue.main.async {
            self.rightDirectionIndicator.alpha = 1.0
            self.rightDirectionIndicator.layer.removeAllAnimations()
            self.leftDirectionIndicator.alpha = 1.0
            self.leftDirectionIndicator.layer.removeAllAnimations()
        }
    }
    
    // MARK: - Node Related
    func shootBullet() {
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR coordinates are in meters
        let bulletDirection = direction
        
        let impulseVector = SCNVector3(
            x: bulletDirection.x * Float(20),
            y: bulletDirection.y * Float(20),
            z: bulletDirection.z * Float(20)
        )
        
        bulletsNode.physicsBody?.applyForce(impulseVector, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
        
        //3 seconds after shooting the bullet, remove the bullet node
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            // remove node
            bulletsNode.removeFromParentNode()
        })
    }
    
    func addPlayer() {
        let newPlayerNode = Player()
        newPlayerNode.position = self.getCameraPosition()
        sceneView.scene.rootNode.addChildNode(newPlayerNode)
        self.playerNode = newPlayerNode
    }
    
    func addTarget() {
        let targetNode = Target()
        let posX = floatBetween(-0.5, and: 0.5)
        let posY = Float(0)
        let posZ = -2
        targetNode.position = SCNVector3(posX, posY, Float(posZ)) // SceneKit/AR coordinates are in meters
        sceneView.scene.rootNode.addChildNode(targetNode)
        gameHelper.liveTargets.append(targetNode)
        
        self.directNodeTowardCamera(targetNode)
        
        print("Added Target! Position:\(targetNode.position)")
    }
    
    func addInitialTarget() {
        //Add initial target after 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.addTarget()
        })
    }
    
    func beginPlaying() {        
        self.userScore = 0
        gameHelper.state = .Playing
        self.fireParticleNode?.removeFromParentNode()
        
        self.addPlayer()
        self.addInitialTarget()
        self.hideDirectionIndicators()
    }
    
    func endPlaying() {
        DispatchQueue.main.async {
            self.statusLabel.text = "You're dead, loser!\nTap to Play!"
            self.tapGestureRecognizer.isEnabled = false
            
            //Add a delay for re-enabling the tap gesture recognizer so that a user who is spam clicking to shoot will notice that he died and not be confused about why his score went to 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.tapGestureRecognizer.isEnabled = true
            })
            
            self.hideDirectionIndicators()
        }
        
        gameHelper.state = .TapToPlay
    }
    
    func directNodeTowardCamera(_ node: SCNNode) {
        node.physicsBody?.clearAllForces()
        //Make cube node go towards camera
        let (_, playerPosition) = self.getCameraVector()
        let impulseVector = SCNVector3(
            x: self.randomOneOfTwoInputFloats(-0.50, and: 0.50),
            y: playerPosition.y,
            z: playerPosition.z
        )
        
        //Makes generated nodes rotate when applied with force
        let positionOnNodeToApplyForceTo = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        
        node.physicsBody?.applyForce(impulseVector, at: positionOnNodeToApplyForceTo, asImpulse: true)
    }
    
    func removeNode(_ node: SCNNode) {
        if node is Target {
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: "art.scnassets/")
            //let particleSize = particleSystem?.particleSize
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            // place explosion where node is
            systemNode.position = node.presentation.position
            //node.addChildNode(systemNode)
            sceneView.scene.rootNode.addChildNode(systemNode)
            
            if let target = node as? Target
            {
                if let targetIndex = gameHelper.liveTargets.index(of: target)
                {
                    gameHelper.liveTargets.remove(at: targetIndex)
                }
            }
        }else if node is Player {
            let particleSystem = SCNParticleSystem(named: "fire", inDirectory: "art.scnassets/")
            //let particleSize = particleSystem?.particleSize
            self.fireParticleNode = SCNNode()
            self.fireParticleNode?.addParticleSystem(particleSystem!)
            // place fire where camera is
            self.fireParticleNode?.position = SCNVector3Make(node.presentation.position.x, node.presentation.position.y, node.presentation.position.z - 0.5)
            sceneView.pointOfView!.addChildNode(self.fireParticleNode!)
        }
        // remove node
        node.removeFromParentNode()
    }
    
    func getTargetVector(for target: Target?) -> (SCNVector3, SCNVector3) { // (direction, position)
        guard let target = target else {return (SCNVector3Zero, SCNVector3Zero)}
        
        let mat = target.presentation.transform // 4x4 transform matrix describing target node in world space
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of target node in world space
        let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of target node world space

        return (dir, pos)
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3Zero, SCNVector3Zero)
    }
    
    func getCameraVector() -> (SCNVector3, SCNVector3)  { // (direction, position)
        
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(mat.m31, mat.m32, mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3Zero, SCNVector3Zero)
    }
    
    func getCameraPosition() -> SCNVector3 {
        let (_ , position) = self.getCameraVector()
        return position
    }
    
    func floatBetween(_ first: Float,  and second: Float) -> Float { // random float between upper and lower bound (inclusive)
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    func randomOneOfTwoInputFloats(_ first: Float, and second: Float) -> Float {
        let array = [first, second]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        
        return array[randomIndex]
    }
}

    // MARK: - SCNPhysicsContactDelegate
extension ViewController : SCNPhysicsContactDelegate
{
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.bullets.rawValue) ||
            (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bullets.rawValue && contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
            //target was hit from bullet!
            print("Hit target!")
            
            self.removeNode(contact.nodeB)
            self.removeNode(contact.nodeA)
            self.userScore += 1
            
            self.addTarget()
        }else if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue) ||
            (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.player.rawValue &&
                contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue){
            //Player was hit by target!
            print("Player Dead!")
            
            self.removeNode(contact.nodeA)
            self.removeNode(contact.nodeB)
            
            self.endPlaying()
        }
    }
}

    // MARK: - ARSessionDelegate
extension ViewController : ARSessionDelegate
{
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //TODO: See if there's a better way to update player position instead of repositioning it everytime
        //      the camera gets a new frame
        self.playerNode?.position = self.getCameraPosition()
        self.displayDirectionIndicatorsIfAppropriate()
    }
}

    // MARK: - SCNSceneRendererDelegate
extension ViewController : SCNSceneRendererDelegate
{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

    }
}
