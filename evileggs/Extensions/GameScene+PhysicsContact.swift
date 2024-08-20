//
//  GameScene+PhysicsContact.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
            
            // MARK: - Monster | Projectile
            
        case PhysicsBody.monster.categoryBitMask | PhysicsBody.projectile.categoryBitMask:
            let monsterNode = contact.bodyA.categoryBitMask ==
            PhysicsBody.monster.categoryBitMask ? contact.bodyA.node : contact.bodyB.node
            
            let projectileNode = contact.bodyA.categoryBitMask ==
            PhysicsBody.projectile.categoryBitMask ? contact.bodyA.node : contact.bodyB.node
            
            // TODO: Monster Gets Hurt...
            if let healthComponent = monsterNode?.entity?.component(ofType: MonsterComponent.self) {
                healthComponent.updateHealth(-1) {
                    for (i, monsters) in monsterPaths {
                        for _ in monsters {
                            monsterPaths[i]!.removeAll(where: { $0 == monsterNode })
                        }
                    }
                    score += 10
                }
                projectileNode?.removeFromParent()
            }
            
            // MARK: - Monster | Wall
            
        case PhysicsBody.monster.categoryBitMask | PhysicsBody.wall.categoryBitMask:
            let monsterNode = contact.bodyA.categoryBitMask ==
            PhysicsBody.monster.categoryBitMask ? contact.bodyA.node : contact.bodyB.node
            
            let wallNode = contact.bodyA.categoryBitMask ==
            PhysicsBody.wall.categoryBitMask ? contact.bodyA.node : contact.bodyB.node
            
            // TODO: Wall Gets Damaged and Monster Dies...
            
            // MARK: - Monster | Turret
            
        case PhysicsBody.monster.categoryBitMask | PhysicsBody.activeTurretSlot.categoryBitMask:
            let monsterNode = contact.bodyA.categoryBitMask ==
            PhysicsBody.monster.categoryBitMask ? contact.bodyA.node : contact.bodyB.node
            
            let turretNode = contact.bodyA.categoryBitMask ==
            PhysicsBody.activeTurretSlot.categoryBitMask ? contact.bodyA.node : contact.bodyB.node
            
            // TODO: Turret Dies and Monster Dies...
            monsterNode?.removeFromParent()
            for (i, monsters) in monsterPaths {
                for _ in monsters {
                    monsterPaths[i]!.removeAll(where: { $0 == monsterNode })
                }
            }
            
        default:
            break
        }
    }
    
}
