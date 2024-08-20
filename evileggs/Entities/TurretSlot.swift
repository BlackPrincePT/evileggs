//
//  TurretSlot.swift
//  evileggs
//
//  Created by Petre Chkonia on 28.07.24.
//

import SpriteKit
import GameplayKit

class TurretSlot: SKSpriteNode {
    
    let stateMachine = GKStateMachine(states: [TurretSlotIsOccupiedState(), TurretSlotIsEmptyState()])
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        stateMachine.enter(TurretSlotIsEmptyState.self)
    }
    
    var turretNode: Turret?
    
    func place(turret: Turret?) {
        turretNode = turret
        turretNode?.position = position
        
        stateMachine.enter(TurretSlotIsOccupiedState.self)
    }
    
    func removeTurret() {
        turretNode = nil
        stateMachine.enter(TurretSlotIsEmptyState.self)
    }
}
