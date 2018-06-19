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
    var e:[Int] = []
    
    var trainingPoints:[TrainingPoint] = []
    var placedPatterns:[String] = []
    
    var patternsBar:PatternsBar = PatternsBar()
    
    var numDecisionBoundaries = 1
    
    var timer:Timer = Timer()
    
    var currentPointIndex = 0
    var numEpochs = 0
    var numTrainingCorrect = 0
    
    var isTraining = false
    var isThinking = false
    var isDecisionBoundaryUp = false
    
    var currentView = 0 //0: Euclidean, 1: Network
    
    var isFirstTimeRunningSet = true
    
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
        let targetBlank = SKSpriteNode(color: .white, width: self.frame.height, height: self.frame.height-invisibleTopBar.size.height-patternsBar.size.height-self.frame.width/8-40, anchorPoint: CGPoint(x:0,y:0), position: CGPoint(x:0,y:self.frame.width/8+40), zPosition: -2, alpha: 1)
        targetBlank.name = "trainingSpace"
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
        swipeLeftGesture.direction = .left
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
        swipeRightGesture.direction = .right
        self.view?.addGestureRecognizer(swipeLeftGesture)
        self.view?.addGestureRecognizer(swipeRightGesture)
        self.addChild(targetBlank)
        
        let loading = SKSpriteNode(imageName: "1", width: self.frame.width/8, height: self.frame.width/8, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:self.frame.height/2), zPosition: 4, alpha: 0)
        loading.name = "loading"
        self.addChild(loading)
        
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
        
        let nonLinearizable = SKSpriteNode(color: ThemeColor.darkPurple, width: self.frame.width/2, height: self.frame.width/5, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:-1000), zPosition: 0, alpha: 1)
        nonLinearizable.name = "nonLinear"
        let nonLinearizableLabel = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: "NonLinearizable", fontColor: .white, fontName: "Antipasto Pro", fontSize: 25, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        nonLinearizable.addChild(nonLinearizableLabel)
        self.addChild(nonLinearizable)
        
        //Prepare Default Weights and Biases
        (weights,biases) = NeuralNet.setDefaultWeightsAndBiases(numInputs: 2, numOutputs: 7)
        
    }
    
    @objc func swipe(_ swipe:UISwipeGestureRecognizer){
        
        var isAllUntoggled = true
        for pattern in patternsBar.patterns{
            if pattern.isToggled{
                isAllUntoggled = false
            }
        }
        
        if swipe.direction == .left && currentView == 0 && isAllUntoggled{//Go to Right Screen
            currentView = 1
            for s in self.children{
                if s.name == "bar" || s.name == "trainingSpace" || s.name == "loading" || s.name == "nonLinear" || s.name == "line" || s.name == "point"{
                    let move = SKAction.moveBy(x: -self.frame.width, y: 0, duration: 0.2)
                    s.run(move)
                }
            }
        }
        if swipe.direction == .right && currentView == 1 && isAllUntoggled{//Go to Left Screen
            currentView = 0
            for s in self.children{
                if s.name == "bar" || s.name == "trainingSpace" || s.name == "loading" || s.name == "nonLinear" || s.name == "line" || s.name == "point"{
                    let move = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.2)
                    s.run(move)
                }
            }
        }
    }
    
    @objc func perceptronIterate(){
        (weights,biases,e) = NeuralNet.perceptronIteration(testInput: [trainingPoints[currentPointIndex].normX,trainingPoints[currentPointIndex].normY], testClass: NeuralNet.patternTypeToPattern(patternType:trainingPoints[currentPointIndex].patternType,patterns: patternsBar.patterns), weights: weights, bias: biases)
        print("iterated")
        
        for node in self.children{
            if node.name  == "line"{
                node.removeFromParent()
            }
        }
        print(weights)
        print(currentPointIndex)
        for rowIndex in 0..<weights.count{
            var yIntercept = CGPoint(x:0,y:-1000*biases[rowIndex]/weights[rowIndex][1])
            
            var slope = -weights[rowIndex][0]/weights[rowIndex][1]
            var endPoint = CGPoint(x:self.frame.width,y:self.frame.width*slope)
            print(weights[rowIndex][0])
            print(weights[rowIndex][1])
            print(biases)
            print(yIntercept)
            print(slope)
            print()
            
            var path = CGMutablePath()
            path.move(to: yIntercept)
            path.addLine(to: endPoint)
            
            let shape = SKShapeNode()
            shape.path = path
            shape.name = "line"
            shape.strokeColor = ThemeColor.darkPurple
            shape.lineWidth = 4
            shape.zPosition = -1
            self.addChild(shape)
        }
        
        if numEpochs >= 0{
            var done = true
            for i in e{
                if i != 0{
                    done = false
                }
            }
            if done{
                numTrainingCorrect += 1
            }
            
            if numTrainingCorrect == trainingPoints.count{
                timer.invalidate()
                isTraining = false
                for s in self.children{
                    if s.name == "play"{
                        s.removeAllActions()
                        let sprite = s as! SKSpriteNode
                        sprite.texture = SKTexture(imageNamed:"play")
                    }
                }
                print("hi")
            }else{
                print("again")
                if currentPointIndex+1 == trainingPoints.count{
                    currentPointIndex = 0
                    numEpochs+=1
                    numTrainingCorrect  = 0
                }else{
                    currentPointIndex+=1
                }
            }
            
        }
        
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
                            if s.name == "point" || s.name == "line"{
                                s.removeFromParent()
                            }
                        }
                        isFirstTimeRunningSet = true
                    }
                    
                    if sprite.name == "play" && !isTraining && !isDecisionBoundaryUp && !isThinking{
                        currentPointIndex = 0
                        numEpochs = 0
                        numTrainingCorrect = 0
                        isTraining = true
                        
                        let animate = SKAction.animate(with: [SKTexture(imageNamed: "1"),SKTexture(imageNamed: "2"),SKTexture(imageNamed: "3"),SKTexture(imageNamed: "4"),SKTexture(imageNamed: "5"),SKTexture(imageNamed: "6"),SKTexture(imageNamed: "7"),SKTexture(imageNamed: "8")], timePerFrame: 0.06)
                        let rep = SKAction.repeatForever(animate)
                        sprite.run(rep)
                        if isFirstTimeRunningSet{
                            weights = NeuralNet.setDefaultWeightsAndBiases(numInputs: 2, numOutputs: 7).weightMatrix
                            biases = NeuralNet.setDefaultWeightsAndBiases(numInputs: 2, numOutputs: 7).biasVector
                        }
                        isFirstTimeRunningSet = false
                        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.perceptronIterate), userInfo: nil, repeats: true)
                    }
                    
                    if sprite.name == "trainingSpace"{
                        print("training")
                        for p in patternsBar.patterns{
                            if p.isToggled && !isDecisionBoundaryUp && !isThinking && !isTraining{
                                let point = TrainingPoint(position: touch.location(in: self), pattern: p, myScene: self)
                                point.name = "point"
                                isThinking = true
                                
                                for s in self.children{
                                    if s.name == "loading"{
                                        s.alpha = 1
                                        
                                        let animate = SKAction.animate(with: [SKTexture(imageNamed: "1"),SKTexture(imageNamed: "2"),SKTexture(imageNamed: "3"),SKTexture(imageNamed: "4"),SKTexture(imageNamed: "5"),SKTexture(imageNamed: "6"),SKTexture(imageNamed: "7"),SKTexture(imageNamed: "8")], timePerFrame: 0.06)
                                        let rep = SKAction.repeatForever(animate)
                                        s.run(rep)
                                    }
                                }
                                
                                if let boundaryCountDelta = NeuralNet.addTrainingPoint(point:point,placedPatterns: placedPatterns,numDecisionBoundaries:numDecisionBoundaries,trainingPoints:trainingPoints,patternBar:patternsBar,weights:weights,biases:biases){
                                    numDecisionBoundaries+=boundaryCountDelta
                                    print("Bounds: "+String(numDecisionBoundaries))
                                    print(boundaryCountDelta)
                                    
                                    isThinking = false
                                    for s in self.children{
                                        if s.name == "loading"{
                                            s.alpha = 0
                                            s.removeAllActions()
                                        }
                                    }
                                    
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
                                    (weights,biases) = NeuralNet.train(points: trainingPoints, patternBar: patternsBar.patterns, weights: weights, biases: biases)!
                                }else{
                                    //Nonlinearizable
                                    print("Nonlinearizable")
                                    isThinking = false
                                    for s in self.children{
                                        if s.name == "loading"{
                                            s.alpha = 0
                                            s.removeAllActions()
                                        }
                                    }
                                    for s in self.children{
                                        if s.name == "nonLinear"{
                                            isDecisionBoundaryUp = true
                                            let moveUp = SKAction.moveTo(y: self.frame.height/2, duration: 0.2)
                                            let wait = SKAction.wait(forDuration: 1.3)
                                            let moveDown = SKAction.moveTo(y: -1000, duration: 0.2)
                                            let toggle = SKAction.run({
                                                self.isDecisionBoundaryUp = false
                                            })
                                            let seq = SKAction.sequence([moveUp,wait,moveDown,toggle])
                                            s.run(seq)
                                        }
                                    }
                                    
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


