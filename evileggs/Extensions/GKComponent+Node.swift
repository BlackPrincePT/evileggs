//
//  GKComponent+Node.swift
//  evileggs
//
//  Created by Petre Chkonia on 27.07.24.
//

import SpriteKit
import GameplayKit

extension GKComponent {
    
    var componentNode: SKNode {
        
        if let node = entity?.component(ofType: GKSKNodeComponent.self)?.node {
            return node
            
        } else if let node = entity?.component(ofType: RenderComponent.self)?.spriteNode {
            return node
        }
        
        return SKNode()
    }
    
}
