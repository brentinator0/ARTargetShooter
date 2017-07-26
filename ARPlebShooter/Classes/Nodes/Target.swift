//
//  Target.swift
//  ARPlebShooter
//
//  Created by Brent Piephoff on 7/26/17.
//  Copyright © 2017 Brent Piephoff. All rights reserved.
//

import UIKit
import SceneKit

// Floating boxes that appear around you
class Target: SCNNode {
    override init() {
        super.init()
        var geometry:SCNGeometry
        
        switch ShapeType.random() {
        case .Box:
            geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.0)
        case .Sphere:
            geometry = SCNSphere(radius: 0.025)
        case .Capsule:
            geometry = SCNCapsule(capRadius: 0.015, height: 0.035)
        case .Cylinder:
            geometry = SCNCylinder(radius: 0.02, height: 0.05)
        }

        
        self.geometry = geometry
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.charge = -0.5
        self.physicsBody?.categoryBitMask = CollisionCategory.target.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        self.physicsBody?.collisionBitMask = CollisionCategory.target.rawValue
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "abstract")
        self.geometry?.materials  = [material, material, material, material, material, material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum ShapeType:Int {
    case Box = 0
    case Sphere
    case Capsule
    case Cylinder
    
    static func random() -> ShapeType {
        let maxValue = Cylinder.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
}
