//
//  GameScene.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

/*
 Task to complete before publishing:
 -When calculating point, make a loading spinning node appear
 */

import SpriteKit
import GameplayKit

class HomeScene: SKScene {
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        let titleLabel = SKLabelNode(position: CGPoint(x:self.frame.width/2,y:self.frame.height*0.7), zPosition: 1, text: "Single Layer Perceptron Network", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 25, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        self.addChild(titleLabel)
        
        let animationLabel = SKLabelNode(position: CGPoint(x:self.frame.width/2,y:self.frame.height*0.7-30), zPosition: 1, text: "A Training Animation", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        self.addChild(animationLabel)
        
        let playButton = SKSpriteNode(imageName: "play", width: self.frame.width/6, height: self.frame.width/6, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/3,y:self.frame.height/2), zPosition: 1, alpha: 1)
        playButton.name = "play"
        self.addChild(playButton)
        
        let infoButton = SKSpriteNode(imageName: "info", width: self.frame.width/6, height: self.frame.width/6, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width*2/3,y:self.frame.height/2), zPosition: 1, alpha: 1)
        infoButton.name = "info"
        self.addChild(infoButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            for sprite in self.children{
                if sprite.contains(touch.location(in: self)){
                    if sprite.name == "play"{
                        let scene = PlayScene(size: self.size)
                        view?.presentScene(scene, transition:SKTransition.push(with: .right, duration: 0.3))
                    }
                    if sprite.name ==  "info"{
                        let scene = InfoScene(size: self.size)
                        view?.presentScene(scene, transition:SKTransition.push(with: .left, duration: 0.3))
                    }
                }
                
            }
            
        }
    }
}
