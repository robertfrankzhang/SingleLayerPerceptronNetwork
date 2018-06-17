//
//  PatternsBar.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import SpriteKit

class PatternsBar:SKSpriteNode{
    var myScene:SKScene
    var patterns:[Pattern] = []
    
    init(myScene:SKScene,position:CGPoint) {
        self.myScene = myScene
        
        super.init(texture: SKTexture(), color:.white, size: CGSize(width:myScene.frame.width,height:myScene.frame.width/8))
        self.zPosition = 1
        self.colorBlendFactor = 1
        self.alpha = 1
        self.name = "bar"
        self.position  = position
        
        //Generate 8 Patterns
        for x in 1...8{
            patterns.append(Pattern(color: generateColor(), name: "Pattern "+String(x),outputVectorNumRows:7))
        }
        
        //Generate pattern palette
        for x in 0..<8{
            let sprite:SKSpriteNode = SKSpriteNode(color: patterns[x].color, width: myScene.frame.width/8, height: myScene.frame.width/8, anchorPoint: CGPoint(x:0,y:0.5), position: CGPoint(x:myScene.frame.width*CGFloat(x)/8-self.frame.width/2,y:0), zPosition: 1, alpha: 1)
            sprite.name = "Pattern "+String(x+1)
            self.addChild(sprite)
        }
    }
    
    init(){
        self.myScene = SKScene()
        super.init(texture: SKTexture(), color:.black, size: CGSize(width:0,height:30))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func generateColor()->UIColor{
        while true{
            let randomRed = CGFloat(arc4random_uniform(255))
            let randomGreen = CGFloat(arc4random_uniform(255))
            let randomBlue = CGFloat(arc4random_uniform(255))
            
            var colorValid = true
            
            for pattern in patterns{
                let color =  pattern.color.rgb()
                let red = (color?.red)!*255
                let green = (color?.green)!*255
                let blue = (color?.blue)!*255
                
                let distance = sqrt(pow(randomRed-red,2)+pow(randomGreen-green,2)+pow(randomBlue-blue,2)) //Euclidean distance between RGB values
                
                if distance < 150 || (randomRed > 210 && randomGreen > 210 && randomBlue > 210){//Filter to ensure pattern colors are not similar, and not too light
                    colorValid = false
                }
            }
            
            if colorValid{
                return UIColor(red: randomRed/255, green: randomGreen/255, blue: randomBlue/255, alpha: 1)
            }
        }
    }
}

