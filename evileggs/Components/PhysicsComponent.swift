//
//  PhysicsComponent.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit
import GameplayKit

enum PhysicsCategory: String {
    case monster
    case projectile
    case wall
    case activeTurretSlot
}

enum PhysicsShape: String {
    case circle
    case rect
}

struct PhysicsBody: OptionSet, Hashable {
    
    let rawValue: UInt32
    
    static let monster = PhysicsBody(rawValue: 1 << 0) //1
    static let projectile = PhysicsBody(rawValue: 1 << 1) //2
    static let wall = PhysicsBody(rawValue: 1 << 2) //4
    static let activeTurretSlot = PhysicsBody(rawValue: 1 << 3) //8
    
    static var collisions: [PhysicsBody: [PhysicsBody]] = [
        .monster: [.wall]
    ]
    
    static var contactTests: [PhysicsBody: [PhysicsBody]] = [
        .monster: [.projectile, .wall, .activeTurretSlot],
        .projectile: [.monster],
        .wall: [.monster],
        .activeTurretSlot: [.monster]
    ]
    
    var categoryBitMask: UInt32 {
        return rawValue
    }
    
    var collisionBitMask: UInt32 {
        let bitMask = PhysicsBody.collisions[self]?.reduce(PhysicsBody()) { partialResult, physicsBody in
            return partialResult.union(physicsBody)
        }
        return bitMask?.rawValue ?? 0
    }
    
    var contactTestBitMask: UInt32 {
        let bitMask = PhysicsBody.contactTests[self]?.reduce(PhysicsBody()) { partialResult, physicsBody in
            return partialResult.union(physicsBody)
        }
        return bitMask?.rawValue ?? 0
    }
    
    static func forType(_ type: PhysicsCategory?) -> PhysicsBody? {
        
        switch type {
        case .monster:
            return self.monster
        case .projectile:
            return self.projectile
        case .wall:
            return self.wall
        case .activeTurretSlot:
            return self.activeTurretSlot
        default:
            break
        }
        
        return nil
    }
}

// MARK: - COMPONENT CODE STARTS HERE

class PhysicsComponent: GKComponent {
    
    @GKInspectable var bodyType: String = PhysicsCategory.monster.rawValue
    @GKInspectable var bodyShape: String = PhysicsShape.rect.rawValue
    
    override func didAddToEntity() {
        
        guard let bodyCategory = PhysicsBody.forType(PhysicsCategory(rawValue: bodyType)),
              let sprite = componentNode as? SKSpriteNode else { return }
        
        let size: CGSize = sprite.size
        
        if bodyShape == PhysicsShape.rect.rawValue {
            componentNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        } else if bodyShape == PhysicsShape.circle.rawValue {
            componentNode.physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2)
        }
        
        componentNode.physicsBody?.categoryBitMask = bodyCategory.categoryBitMask
        componentNode.physicsBody?.collisionBitMask = bodyCategory.collisionBitMask
        componentNode.physicsBody?.contactTestBitMask = bodyCategory.contactTestBitMask
        
        componentNode.physicsBody?.affectedByGravity = false
        componentNode.physicsBody?.allowsRotation = false
    }
    
    override class var supportsSecureCoding: Bool { true }
}
