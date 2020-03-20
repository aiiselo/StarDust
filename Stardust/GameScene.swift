//
//  GameScene.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 12.02.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let girl = SKSpriteNode(imageNamed: "GG1")
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    let girlMovePointsPerSec: CGFloat = 250.0
    var velocity = CGPoint.zero // вектор скорости спрайта (кол-во точек / сек)
    let playableRect: CGRect
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    var touchLocation: CGPoint?
    let girlAnimation: SKAction
    let asteroidAnimation: SKAction
    
    override init(size: CGSize) {
        let maxApectRatio: CGFloat = deviceHeight / deviceWidth
        let playableWidth = size.height / maxApectRatio
        // сцена заполняется полностью, чтобы центрировать воспроизводимый прямоугольник на экран, для этого край сверху и снизу высчитывается как  (высота сцены - воспроизводимая высота) /2
        let playableMargin = (size.width - playableWidth) / 2.0
        // пря-ник с максимальным соотношением сторон, в центре которого находится экран
        playableRect = CGRect(x: 0, y: playableMargin, width: playableWidth, height: size.height)
        var texturesGirl:[SKTexture] = []
        for i in 1...6 {
            texturesGirl.append(SKTexture(imageNamed: "GG\(i)"))
        }
        girlAnimation = SKAction.animate(with: texturesGirl, timePerFrame: 0.1)
        var texturesAsteroid: [SKTexture] = []
        for i in 1...6 {
            texturesAsteroid.append(SKTexture(imageNamed: "Ast\(i)"))
        }
        asteroidAnimation = SKAction.animate(with: texturesAsteroid, timePerFrame: 0.05)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black // начальные настройки сцены
        let background = SKSpriteNode(imageNamed: "backgroundSpace")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize(width: background.size.width / (background.size.height / deviceHeight), height: deviceHeight)
        background.zPosition = -1
        addChild(background)
        girl.position = CGPoint(x: background.size.width / 2, y: 250)
        addChild(girl)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
            [weak self] in self?.generateAsteroid()
        }),
                                                      SKAction.wait(forDuration: 5.0)])))
        drawPlayableArea()
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        }
        else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        /** COMMENT CODE BLOCK BELOW FOR ANOTHER GIRL MOVING */
        if let touchLocation_ = touchLocation {
            let distancePoint = CGPoint(x: touchLocation_.x - girl.position.x, y: touchLocation_.y - girl.position.y)
            let distance = sqrt(pow(distancePoint.x, 2) + pow(distancePoint.y, 2))
            if distance <= girlMovePointsPerSec * CGFloat(deltaTime) {
                velocity = CGPoint.zero
                girl.position = touchLocation!
                stopAnimation(sprite: girl, spriteAction: girlAnimation)
            }
            else {
                move(sprite: girl, velocity: velocity)
                flipSprite(sprite: girl, velocity: velocity)
            }
        }
        /** COMMENT CODE BLOCK BELOW FOR ANOTHER GIRL MOVING */
        
//        move(sprite: girl, velocity: velocity)
//        flipSprite(sprite: girl, velocity: velocity)
//        boundsCheck()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(deltaTime), y: velocity.y * CGFloat(deltaTime))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    func moveGirl(location: CGPoint) {
        startAnimation(sprite: girl, spriteAction: girlAnimation)
        let offset = CGPoint(x:location.x - girl.position.x, y:location.y - girl.position.y)
        let length = sqrt(pow(offset.x, 2) + pow(offset.y, 2))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length)) // нормированный вектор
        velocity = CGPoint(x: direction.x * girlMovePointsPerSec, y: direction.y * girlMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation_: CGPoint) {
        touchLocation = touchLocation_
        moveGirl(location: touchLocation_)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        sceneTouched(touchLocation_: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        sceneTouched(touchLocation_: touch.location(in: self))
    }
    
    /** UNCOMMENT FOR ANOTHER GIRL MOVING */
    
//     func boundsCheck(){
//         let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
//         let topRight = CGPoint(x: playableRect.maxX, y: playableRect.maxY)
//         if bottomLeft.x >= girl.position.x {
//             girl.position.x = bottomLeft.x
//             velocity.x *= -1
//         }
//         if topRight.x <= girl.position.x {
//             girl.position.x = topRight.x
//             velocity.x *= -1
//         }
//         if bottomLeft.y >= girl.position.y {
//             girl.position.y = bottomLeft.y
//             velocity.y *= -1
//         }
//         if topRight.y <= girl.position.y {
//             girl.position.y = topRight.y
//             velocity.y *= -1
//         }
//     }

    func drawPlayableArea() {
        let shape = SKShapeNode()
        shape.strokeColor = SKColor.black
        shape.lineWidth = 8
        addChild(shape)
    }
    
    func flipSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        if velocity.x < 0 {
            sprite.xScale = -1;
        }
        if velocity.x > 0 {
            sprite.xScale = 1;
        }
    }
    
    func generateAsteroid() {
        let timeIntervalAsteroid: TimeInterval = TimeInterval(Float.random(in: 1 ... 3))
        let asteroid = SKSpriteNode(imageNamed: "Ast1")
        asteroid.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let positionX = Int.random(in: 0 ... Int(size.width))
        asteroid.position = CGPoint(x: positionX, y: Int(size.height) + Int(asteroid.size.height) / 2)
        addChild(asteroid)
        let actionDownStraight = SKAction.move(to: CGPoint(x: positionX, y: 0 - Int(asteroid.size.height) / 2), duration: timeIntervalAsteroid)
        let actionDownRight = SKAction.move(to: CGPoint(x: Int(size.width)/2 + Int(size.width)/4, y: 0 - Int(asteroid.size.height) / 2), duration: timeIntervalAsteroid)
        let actionDownLeft = SKAction.move(to: CGPoint(x: Int(size.width)/2 - Int(size.width)/4, y: 0 - Int(asteroid.size.height) / 2), duration: timeIntervalAsteroid)
        let actionDelete = SKAction.removeFromParent()
        let randomMove = Int.random(in: 0 ..< 3)
        if randomMove == 0 {
            startAnimation(sprite: asteroid, spriteAction: asteroidAnimation)
            asteroid.run(SKAction.sequence([actionDownStraight, actionDelete]))
        }
        if randomMove == 1 {
            startAnimation(sprite: asteroid, spriteAction: asteroidAnimation)
            asteroid.run(SKAction.sequence([actionDownLeft, actionDelete]))
        }
        if randomMove == 2 {
            startAnimation(sprite: asteroid, spriteAction: asteroidAnimation)
            asteroid.run(SKAction.sequence([actionDownRight, actionDelete]))
        }
    }
    
    func startAnimation(sprite: SKSpriteNode, spriteAction:SKAction) {
        if sprite.action(forKey: "animation") == nil {
            sprite.run(SKAction.repeatForever(spriteAction), withKey: "animation")
        }
    }
    
    func stopAnimation(sprite: SKSpriteNode, spriteAction:SKAction) {
        sprite.removeAction(forKey: "animation")
    }
}
