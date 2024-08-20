//
//  MonsterHealthComponent.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit
import GameplayKit

struct Monster {
    
    let type: GameObjectType
    
    let currentHealth: Int
    let maxHealth: Int
    
    let speed: Int
    
    init(type: GameObjectType, maxHealth: Int, speed: Int) {
        self.type = type
        self.currentHealth = maxHealth
        self.maxHealth = maxHealth
        self.speed = speed
    }
}

class MonsterComponent: GKComponent {
    
    @GKInspectable var monsterType: String = GameObject.defaultMonsterType
    
    private var currentHealth: Int!
    private var maxHealth: Int!
    
    private var speed: Int!
    
    override func didAddToEntity() {
        
        let renderComponent = RenderComponent(imageNamed: "monster_\(monsterType)")
        entity?.addComponent(renderComponent)
        
        let physicsComponent = PhysicsComponent()
        physicsComponent.bodyType = PhysicsCategory.monster.rawValue
        entity?.addComponent(physicsComponent)
        
        setupSettings()
        
        setupHealthComponent()
    }
    
    func setupSettings() {
        
        guard let monster = GameObject.forMonsterType(GameObjectType(rawValue: monsterType)) else { return }
        
        currentHealth = monster.currentHealth
        maxHealth = monster.maxHealth
        speed = monster.speed
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        componentNode.physicsBody?.velocity = CGVector(dx: 0, dy: -speed)
    }
    
    // MARK: - Health
    
    private let healthBarFull = SKTexture(imageNamed: "health_bar").size().width
    
    func setupHealthComponent() {
        if let healthBar = SKReferenceNode(fileNamed: "HealthBar") {
            healthBar.position = CGPoint(x: 0, y: componentNode.frame.size.height / 2 + 16)
            componentNode.addChild(healthBar)
            
            updateHealth(0) {
                
            }
        }
    }
    
    func updateHealth(_ value: Int, completion: () -> Void) {
        
        currentHealth += value
        
        if currentHealth > maxHealth {
            currentHealth = maxHealth
        }
        
        if value < 0 {
            if currentHealth <= 0 {
                componentNode.removeFromParent()
                completion()
            } else {
                // Hurt
            }
        }
        
        updateHealthBar()
    }
    
    func updateHealthBar() {
        
        if let barHP = componentNode.childNode(withName: ".//health_bar") as? SKSpriteNode {
            
            let hpPercentage: Double = max(0, min(1, Double(currentHealth) / Double(maxHealth)))
            
            barHP.size.width = healthBarFull *  hpPercentage
        }
    }
    
    override class var supportsSecureCoding: Bool { true }
}
