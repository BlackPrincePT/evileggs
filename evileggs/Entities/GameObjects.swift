//
//  GameObjects.swift
//  evileggs
//
//  Created by Petre Chkonia on 30.07.24.
//

import SpriteKit
import GameplayKit

enum GameObjectType: String {
    
    // Monsters
    case basic
    case basicPlus
}

struct GameObject {
    
    static let defaultMonsterType = GameObjectType.basic.rawValue
    
    static let basicMonster = BasicMonster()
    static let basicPlusMonster = BasicPlusMonster()
    
    struct BasicMonster {
        let monsterSettings = Monster(type: .basic, maxHealth: 10, speed: 100)
    }
    
    struct BasicPlusMonster {
        let monsterSetttings = Monster(type: .basicPlus, maxHealth: 20, speed: 70)
    }
    
    static func forMonsterType(_ type: GameObjectType?) -> Monster? {
        
        switch type {
        case .basic:
            return GameObject.basicMonster.monsterSettings
        case .basicPlus:
            return GameObject.basicPlusMonster.monsterSetttings
        default:
            return nil
        }
    }
    
}
