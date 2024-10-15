//
//  Turret.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit
import GameplayKit

class Turret: SKSpriteNode {
    
    var stateMachine = GKStateMachine(states: [TurretIsBeingEdited(), TurretIsNotBeingEdited()])
    
    var maxProjectiles: Int = 1
    var numProjectiles: Int = 0
    
    var projectileRange: CGFloat = 1700
    var projectileSpeed: TimeInterval = 10
    var projectileRate: TimeInterval = 1
    
    let turretTexture = SKTexture(imageNamed: "turret_0")
    
    let shield = SKSpriteNode(imageNamed: "level_background")
    
    let levelLabel = SKLabelNode(fontNamed: "AlfaSlabOne-Regular")
    
    var currentLevel: Int = 1 {
        didSet {
            levelLabel.text = "\(currentLevel)"
            projectileSpeed = 10 - Double(currentLevel) / 4
            projectileRate = 1 - Double(currentLevel) / 20
            
            texture = SKTexture(imageNamed: "turret_\(currentLevel - (currentLevel % 5))")
        }
    }
    
    init() {
        super.init(texture: turretTexture, color: .clear, size: turretTexture.size())
        
        zPosition = DisplayOrder.turret.rawValue
        
        setupShield()
        setupLabel()
        
        stateMachine.enter(TurretIsNotBeingEdited.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupShield() {
        shield.position = CGPoint(x: frame.maxX - 16, y: frame.minY + shield.frame.maxY)
        addChild(shield)
    }
    
    func setupLabel() {
        levelLabel.text = "\(currentLevel)"
        levelLabel.fontColor = .white
        levelLabel.fontSize = 30
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        shield.addChild(levelLabel)
    }
    
    func attack() {
        
        /* Verify the direction isn't zero and that player hasn't
         shot more projectiles than the max allowed at one time */
        if numProjectiles < maxProjectiles {
            
            // Increase the number of "current" projectiles
            numProjectiles += 1
            
            // Set up the projectile
            let projectile = SKSpriteNode(imageNamed: "bullet_red")
            projectile.position = convert(CGPoint(x: 0, y: 0), to: scene ?? self)
            projectile.zPosition = DisplayOrder.projectile.rawValue
            scene?.addChild(projectile)
            
            // Set up phyisics for the projectile
            let physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = false
            physicsBody.isDynamic = true
            
            physicsBody.categoryBitMask = PhysicsBody.projectile.categoryBitMask
            physicsBody.contactTestBitMask = PhysicsBody.projectile.contactTestBitMask
            physicsBody.collisionBitMask = PhysicsBody.projectile.collisionBitMask
            
            projectile.physicsBody = physicsBody
            
            // Set the throw direction
            let throwDirection = CGVector(dx: 0, dy: projectileRange)
            
            // Create and run the actions to attack
            let wait = SKAction.wait(forDuration: projectileSpeed)
            let removeFromScene = SKAction.removeFromParent()
            
            let toss = SKAction.move(by: throwDirection, duration: projectileSpeed)
            
            let actionTTL = SKAction.sequence([wait, removeFromScene])
            
            let actionAttack = SKAction.group([actionTTL, toss])
            projectile.run(actionAttack)
            
            let attackDelay = SKAction.wait(forDuration: projectileRate)
            
            // Set up attack governor (attack speed limiter)
            let reduceCount = SKAction.run { self.numProjectiles -= 1 }
            let reduceSequence = SKAction.sequence([attackDelay, reduceCount])
            run(reduceSequence)
        }
    }
}
