//
//  RenderComponent.swift
//  evileggs
//
//  Created by Petre Chkonia on 30.07.24.
//

import SpriteKit
import GameplayKit

class RenderComponent: GKComponent {
    
    lazy var spriteNode: SKSpriteNode? = {
        entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode
    }()
    
    init(imageNamed: String) {
        super.init()
        
        spriteNode = SKSpriteNode(imageNamed: imageNamed)
    }
    
    override func didAddToEntity() {
        spriteNode?.entity = entity
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var supportsSecureCoding: Bool { true }
}

