//
//  TurretStates.swift
//  evileggs
//
//  Created by Petre Chkonia on 27.07.24.
//

import GameplayKit

class TurretIsBeingEdited: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == TurretIsNotBeingEdited.self
    }
}

class TurretIsNotBeingEdited: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == TurretIsBeingEdited.self
    }
}
