//
//  GameScene.swift
//  evileggs
//
//  Created by Petre Chkonia on 27.07.24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var score: Int = 0 {
        didSet {
            if score.isMultiple(of: 20) {
                if minSpawnInterval >= 1 {
                    minSpawnInterval -= 0.02
                }
                if maxSpawnInterval >= 1.5 {
                    maxSpawnInterval -= 0.03
                }
            }
        }
    }
    
    var turrets = [Turret]()
    
    var idleSlots = [Int: TurretSlot]()
    var activeSlots = [Int: TurretSlot]()
    
    private var allSlots = [TurretSlot]()
    
    private var spawnLocations: [Int: CGFloat] = [
        0: -426.5,
        1: -256,
        2: -85.5,
        3: +85.5,
        4: +256,
        5: +426.5
    ]
    
    var monsterPaths: [Int: [SKSpriteNode]] = [
        0: [],
        1: [],
        2: [],
        3: [],
        4: [],
        5: []
    ]
    
    var minSpawnInterval: TimeInterval = 2.5
    var maxSpawnInterval: TimeInterval = 5.0
    var timer: Timer?
    
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        
        setupTurretSlots()
        
        startSpawning()
        
        physicsWorld.contactDelegate = self
    }
    
    func setupTurretSlots() {
        
        for i in 0...11 {
            
            let idleSlot = childNode(withName: "slot_idle_\(i)") as? TurretSlot
            
            guard let idleTurretSlot = idleSlot else { return }
            
            idleSlots[i] = idleTurretSlot
            allSlots.append(idleTurretSlot)
        }
        
        for i in 0...5 {
            
            let activeSlot = childNode(withName: "slot_active_\(i)") as? TurretSlot
            
            guard let activeTurretSlot = activeSlot else { return }
            
            activeSlots[i] = activeTurretSlot
            allSlots.append(activeTurretSlot)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        for (i, slot) in activeSlots {
            if slot.stateMachine.currentState is TurretSlotIsOccupiedState && !monsterPaths[i]!.isEmpty {
                if slot.turretNode?.stateMachine.currentState is TurretIsNotBeingEdited {
                    slot.turretNode?.attack()
                }
            }
        }
        
        for (_, monsters) in monsterPaths {
            for (i, monster) in monsters.sorted(by: { $0.position.y < $1.position.y }).enumerated() {
                monster.zPosition = DisplayOrder.monster.rawValue - CGFloat(i) * 0.001
            }
        }
    }
    
    //MARK: - GAME FUNCTIONS
    
    /* ############################################################### */
    /*                    GAME FUNCTIONS START HERE                    */
    /* ############################################################### */
    
    func startSpawning() {
        scheduleNextSpawn()
    }
    
    func stopSpawning() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scheduleNextSpawn() {
        let interval = TimeInterval.random(in: minSpawnInterval...maxSpawnInterval)
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(spawnMonsterEntity), userInfo: nil, repeats: false)
    }
    
    
    @objc func spawnMonsterEntity() {
        let monsterEntity = GKEntity()
        
        let randomElement = spawnLocations.randomElement()!
        
        let renderComponent = RenderComponent(imageNamed: "monster_basic_plus")
        monsterEntity.addComponent(renderComponent)
        
        let array: [GameObjectType] = [.basic, .basicPlus]
        
        let monsterComponent = MonsterComponent()
        monsterComponent.monsterType = array.randomElement()!.rawValue
        monsterEntity.addComponent(monsterComponent)
        
        if let monsterNode = monsterEntity.component(ofType: RenderComponent.self)?.spriteNode as? SKSpriteNode {
            monsterNode.position = CGPoint(x: randomElement.value, y: frame.maxY)
            addChild(monsterNode)
             
            entities.append(monsterEntity)
            monsterPaths[randomElement.key]?.append(monsterNode)
        }
        
        scheduleNextSpawn()
    }
    
    func updateSpawnIntervals(min: TimeInterval, max: TimeInterval) {
        minSpawnInterval = min
        maxSpawnInterval = max
    }
    
    
    //MARK: - TOUCH HANDLING
    
    /* ################################################################ */
    /*                    TOUCH HANDLERS STARTS HERE                    */
    /* ################################################################ */
    
    func touchDown(atPoint pos : CGPoint) {
        
        if let addButton = childNode(withName: "purchase_turret_button"), addButton.contains(pos) {
            
            addButton.entity?.component(ofType: PurchaseTurretComponent.self)?.spawnTurret()
        }
        
        for slot in allSlots {
            
            if slot.contains(pos), let turretNode = slot.turretNode {
                
                turretNode.stateMachine.enter(TurretIsBeingEdited.self)
                turretNode.zPosition = DisplayOrder.top.rawValue
                
                turretNode.run(SKAction.scale(to: 1.2, duration: 0.1))
                
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        turrets.filter { $0.stateMachine.currentState is TurretIsBeingEdited }.forEach { turret in
            turret.position = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        turrets.filter { $0.stateMachine.currentState is TurretIsBeingEdited }.forEach { turret in
            turret.stateMachine.enter(TurretIsNotBeingEdited.self)
            
            turret.run(SKAction.scale(to: 1.0, duration: 0.1))
            
            var placedInSlot = false
            
            guard let previousSlot = allSlots.first(where: { $0.turretNode == turret }) else { return }
            
            for slot in allSlots {
                if slot.contains(pos) {
                    
                    if slot.stateMachine.currentState is TurretSlotIsEmptyState {
                        
                        previousSlot.removeTurret()
                        slot.place(turret: turret)
                        
                        placedInSlot = true
                        break
                        
                    } else if slot.stateMachine.currentState is TurretSlotIsOccupiedState &&
                                slot.turretNode?.currentLevel == turret.currentLevel &&
                                slot.turretNode != turret {
                        
                        slot.turretNode?.currentLevel += 1
                        previousSlot.removeTurret()
                        
                        turrets.removeAll(where: { $0 == turret })
                        turret.removeFromParent()
                        
                        placedInSlot = true
                        break
                        
                    } else if let name = slot.name, slot.stateMachine.currentState is TurretSlotIsOccupiedState && name.hasPrefix("slot_active") {
                        
                        previousSlot.removeTurret()
                        previousSlot.place(turret: slot.turretNode)
                        
                        slot.removeTurret()
                        slot.place(turret: turret)
                        
                        placedInSlot = true
                        break
                    }

                }      
            }
            
            if !placedInSlot {
                
                turret.position = previousSlot.position
            }
            
            turret.zPosition = DisplayOrder.turret.rawValue
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}
