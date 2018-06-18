//
//  Play.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayScene: SKScene {
    
    var weights:[[CGFloat]] = []
    var biases:[CGFloat] = []
    
    var trainingPoints:[TrainingPoint] = []
    var placedPatterns:[String] = []
    
    var patternsBar:PatternsBar = PatternsBar()
    
    var numDecisionBoundaries = 1
    
    override func didMove(to view: SKView) {
        //Set Display Items
        self.backgroundColor = .white
        
        //Top Bar Items
        let invisibleTopBar = SKSpriteNode(color: .white, width: self.frame.width, height: self.frame.width/8+40, anchorPoint: CGPoint(x:0,y:1), position: CGPoint(x:0,y:self.frame.height), zPosition: 0, alpha: 1)
        self.addChild(invisibleTopBar)
        
        let titleLabel = SKLabelNode(position: CGPoint(x:self.frame.width/2,y:self.frame.height-30-self.frame.width/16), zPosition: 1, text: "Train", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 30, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        self.addChild(titleLabel)
        
        let backButton = SKSpriteNode(imageName: "back", width: self.frame.width/8, height: self.frame.width/8, anchorPoint: CGPoint(x:0,y:1), position: CGPoint(x:10,y:self.frame.height-30), zPosition: 1, alpha: 1)
        backButton.name = "back"
        self.addChild(backButton)
        
        //Patterns Bar
        patternsBar = PatternsBar(myScene: self, position: CGPoint(x:self.frame.width/2,y:self.frame.height-(self.frame.width/8+40+self.frame.width/16)))
        self.addChild(patternsBar)
        
        //Draw Screen
        let targetBlank = SKSpriteNode(color: .white, width: self.frame.height, height: self.frame.height-invisibleTopBar.size.height-patternsBar.size.height-self.frame.width/8-40, anchorPoint: CGPoint(x:0,y:0), position: CGPoint(x:0,y:self.frame.width/8+40), zPosition: 0, alpha: 1)
        targetBlank.name = "trainingSpace"
        self.addChild(targetBlank)
        
        //Bottom Bar Items
        let invisibleBottomBar = SKSpriteNode(color: .white, width: self.frame.width, height: self.frame.width/8+40, anchorPoint: CGPoint(x:0,y:0), position: CGPoint(x:0,y:0), zPosition: 0, alpha: 1)
        self.addChild(invisibleBottomBar)
        
        let resetLabel = SKLabelNode(position: CGPoint(x:10,y:(self.frame.width/8+40)/2), zPosition: 1, text: "Reset", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 30, verticalAlignmentMode: .center, horizontalAlignmentMode: .left)
        resetLabel.name = "reset"
        self.addChild(resetLabel)
        
        let playButton = SKSpriteNode(imageName: "play", width: self.frame.width/6, height: self.frame.width/6, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:(self.frame.width/8+40)/2), zPosition: 1, alpha: 1)
        playButton.name = "play"
        self.addChild(playButton)
        
        let viewAlgoLabel = SKLabelNode(position: CGPoint(x:self.frame.width-10,y:(self.frame.width/8+40)/2), zPosition: 1, text: "Weights", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 30, verticalAlignmentMode: .center, horizontalAlignmentMode: .right)
        viewAlgoLabel.name = "toggle"
        self.addChild(viewAlgoLabel)
        
        //Prepare Default Weights and Biases
        (weights,biases) = NeuralNet.setDefaultWeightsAndBiases(numInputs: 2, numOutputs: 7)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            for sprite in self.children{
                if sprite.contains(touch.location(in: self)){
                    if sprite.name == "back"{
                        let scene = HomeScene(size: self.size)
                        view?.presentScene(scene, transition:SKTransition.push(with: .left, duration: 0.3))
                    }
                    if sprite.name == "bar"{
                        if let pBar = sprite as? PatternsBar{
                            let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.1)
                            let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
                            let patternTapped = pBar.patterns[Int(touch.location(in: self).x/(self.frame.width/8))]
                            for pattern in pBar.patterns{
                                if pattern.isToggled{
                                    pattern.isToggled = false
                                    for spritePattern in pBar.children{
                                        if spritePattern.name == pattern.name{
                                            spritePattern.run(moveUp)
                                        }
                                    }
                                }
                                else if !pattern.isToggled && pattern.name == patternTapped.name{
                                    for spritePattern in pBar.children{
                                        if spritePattern.name == pattern.name{
                                            spritePattern.run(moveDown)
                                            pattern.isToggled = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if sprite.name == "reset"{
                        placedPatterns = []
                        for p in patternsBar.patterns{
                            p.outputVector = [0,0,0,0,0,0,0]
                        }
                        trainingPoints = []
                        for s in self.children{
                            if s.name == "point"{
                                s.removeFromParent()
                            }
                        }
                    }
                    
                    if sprite.name == "trainingSpace"{
                        for p in patternsBar.patterns{
                            if p.isToggled{
                                let point = TrainingPoint(position: touch.location(in: self), pattern: p, myScene: self)
                                point.name = "point"
                                
                                if let boundaryCountDelta = NeuralNet.addTrainingPoint(point:point,placedPatterns: placedPatterns,numDecisionBoundaries:numDecisionBoundaries,trainingPoints:trainingPoints,patternBar:patternsBar,weights:weights,biases:biases){
                                    numDecisionBoundaries+=boundaryCountDelta
                                    print("Bounds: "+String(numDecisionBoundaries))
                                    print(boundaryCountDelta)
                                    trainingPoints.append(point)
                                    self.addChild(point)
                                    for pp in patternsBar.patterns{
                                        print(pp.outputVector)
                                    }
                                    print()
                                    var hasBeenPlaced = false
                                    for p in placedPatterns{//Check if p was in placed patterns
                                        if p == point.patternType{
                                            hasBeenPlaced = true
                                        }
                                    }
                                    
                                    if !hasBeenPlaced{//Add new pattern if pattern hasn't been placed before
                                        placedPatterns.append(p.name)
                                        print(placedPatterns)
                                    }
                                }else{
                                    //Nonlinearizable
                                    print("Nonlinearizable")
                                }
                                print(weights)
                                print(biases)
                            }
                        }
                    }
                }
                
            }
            
        }
    }
}


