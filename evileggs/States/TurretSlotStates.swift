//
//  TurretSlotStates.swift
//  evileggs
//
//  Created by Petre Chkonia on 27.07.24.
//

import GameplayKit

class TurretSlotIsOccupiedState: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == TurretSlotIsEmptyState.self
    }
}

class TurretSlotIsEmptyState: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == TurretSlotIsOccupiedState.self
    }
}
