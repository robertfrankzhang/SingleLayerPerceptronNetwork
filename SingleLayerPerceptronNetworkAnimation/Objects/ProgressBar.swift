//
//  ProgressBar.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import SpriteKit

class ProgressBar:SKSpriteNode{
    var myScene:SKScene
    var greenBar:SKSpriteNode = SKSpriteNode()
    
    var totalLevels:Int
    var currentLevel:Int = 0
    
    init(myScene:SKScene,totalLevels:Int,position:CGPoint) {
        self.myScene = myScene
        self.totalLevels = totalLevels
        
        super.init(texture: SKTexture(), color:ThemeColor.purple, size: CGSize(width:myScene.frame.width*0.8,height:30))
        self.zPosition = 2
        self.colorBlendFactor = 1
        self.alpha = 1
        self.name = "bar"
        self.position  = position
        
        self.greenBar = SKSpriteNode(color: ThemeColor.darkPurple, width: 10, height: 20, anchorPoint: CGPoint(x:0,y:0.5), position: CGPoint(x:-self.frame.width/2+5, y:0), zPosition: 1, alpha: 1)
        self.addChild(greenBar)
    }
    
    init(){
        self.myScene = SKScene()
        self.totalLevels = 0
        super.init(texture: SKTexture(), color:.black, size: CGSize(width:0,height:30))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(swipe:UISwipeGestureRecognizer){
        if swipe.direction == .right{
            subtractLevel()
        }
        if swipe.direction == .left{
            addLevel()
        }
    }
    
    private func addLevel(){
        if currentLevel < totalLevels-1{
            currentLevel += 1
            let move = SKAction.scale(to: CGSize(width:(self.frame.width-10)*CGFloat(currentLevel)/CGFloat(totalLevels-1),height:greenBar.frame.height), duration: 0.1)
            greenBar.run(move)
        }
    }
    
    private func subtractLevel(){
        if currentLevel > 0{
            currentLevel -= 1
            var endWidth:CGFloat = 0
            if currentLevel == 0{
                endWidth = 10
            }else{
                endWidth = (self.frame.width-10)*CGFloat(currentLevel)/CGFloat(totalLevels-1)
            }
            let move = SKAction.scale(to: CGSize(width:endWidth,height:greenBar.frame.height), duration: 0.1)
            greenBar.run(move)
        }
    }
}
