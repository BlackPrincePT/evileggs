//
//  PurchaseTurretComponent.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit
import GameplayKit

class PurchaseTurretComponent: GKComponent {
    
    // MARK: - Icon
    
    var level: Int = 1 {
        didSet {
            turret.texture = SKTexture(imageNamed: "turret_\(level - (level % 5))")
            levelLabel.text = String(level)
        }
    }
    
    private lazy var levelLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AlfaSlabOne-Regular")
        label.text = String(level)
        label.zPosition += 1
        label.fontColor = .white
        label.fontSize = 30
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }()
    
    private lazy var turret: SKSpriteNode = {
        let turret = SKSpriteNode(imageNamed: "turret_0")
        
        let shield = SKSpriteNode(imageNamed: "level_background")
        shield.position = CGPoint(x: turret.frame.maxX - 16, y: turret.frame.minY + shield.frame.maxY)
        shield.zPosition += 1
        turret.addChild(shield)

        shield.addChild(levelLabel)
        
        return turret
    }()
    
    // MARK: - Price
    
    var price: Int = 0 {
        didSet {
            priceLabel.text = String(price / 1000) + "k"
        }
    }
    
    private lazy var priceLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AlfaSlabOne-Regular")
        label.fontColor = .white
        label.fontSize = 50
        label.zPosition += 1
        label.position = CGPoint(x: componentNode.frame.width / 2 - 48, y: 16)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .right
        componentNode.addChild(label)
        return label
    }()
    
    override func didAddToEntity() {
        price = 100000
        level = 1
        
        turret.setScale(0.75)
        turret.position = CGPoint(x: -componentNode.frame.width / 2 + turret.size.width / 2 + 16, y: 16)
        turret.zPosition += 1
        componentNode.addChild(turret)
    }
    
    func spawnTurret() {
        
        guard let scene = componentNode.scene as? GameScene else { return }
        
        for i in 0...11 {
            
            let idleSlot = scene.childNode(withName: "slot_idle_\(i)") as? TurretSlot
            
            guard let idleSlot = idleSlot, idleSlot.turretNode == nil else { continue }
            
            let turret = Turret()
            turret.currentLevel = level
            
            idleSlot.place(turret: turret)
            
            scene.turrets.append(turret)
            scene.addChild(turret)
            
            break
        }
    }
    
    override class var supportsSecureCoding: Bool { true }
}
