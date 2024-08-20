//
//  PurchaseTurretComponent.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit
import GameplayKit

class PurchaseTurretComponent: GKComponent {
    
    func spawnTurret() {
        
        guard let scene = componentNode.scene as? GameScene else { return }
        let tturret = scene.turrets.sorted(by: { $0.currentLevel > $1.currentLevel}).first?.currentLevel
        
        for i in 0...11 {
            
            let idleSlot = scene.childNode(withName: "slot_idle_\(i)") as? TurretSlot
            
            guard let idleSlot = idleSlot, idleSlot.turretNode == nil else { continue }
            
            let turret = Turret()
            turret.currentLevel = tturret ?? 1
            
            idleSlot.place(turret: turret)
            
            scene.turrets.append(turret)
            scene.addChild(turret)
            
            break
        }
    }
    
    override class var supportsSecureCoding: Bool { true }
}
