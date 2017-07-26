//
//  GameHelper.swift
//  ARPlebShooter
//
//  Created by Brent Piephoff on 7/15/17.
//  Copyright © 2017 Brent Piephoff. All rights reserved.
//

class GameHelper {
    static let sharedInstance = GameHelper()
    
    var score:Int
    var state = GameStateType.TapToPlay
    var liveTargets = [Target]()
    
    private init() {
        score = 0
    }
    
    func resetGame() {
        score = 0
    }
    
    enum GameStateType {
        case TapToPlay
        case Playing
    }
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) //moves 0 bits to left for 0000001
    static let target = CollisionCategory(rawValue: 1 << 1) //moves 1 bits to left for 00000001 then you have 00000010
    static let player = CollisionCategory(rawValue: 1 << 2) //moves 1 bits to left for 00000001 then you have 00000100
}
