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
    var e:[CGFloat] = []
    
    var trainingPoints:[TrainingPoint] = []
    var placedPatterns:[String] = []
    
    var patternsBar:PatternsBar = PatternsBar()
    
    var numDecisionBoundaries = 1
    var decisionBoundaries:[SKShapeNode] = []
    
    var timer:Timer = Timer()
    
    var currentPointIndex = 0
    var numEpochs = 0
    var numTrainingCorrect = 0
    
    var isTraining = false//Is the play button spinning
    var isThinking = false
    var isDecisionBoundaryUp = false
    var finishedTraining = false//Are the weights/biases updated to the current set of placed points
    
    var currentView = 0 //0: Euclidean, 1: Network
    
    var isFirstTimeRunningSet = true
    
    var networkAnimation = NetworkAnimation()
    
    var isTesting = false
    var testingLabel = SKLabelNode()
    var isTestingLabelUp = false
    var playButton = SKSpriteNode()
    var loading = SKLabelNode()
    
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
        
        loading = SKLabelNode(position: CGPoint(x:self.frame.width/2,y:self.frame.height/2), zPosition: 4, text: "Thinking...", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 15, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        loading.alpha = 0
        loading.name = "loading"
        self.addChild(loading)
        
        //Bottom Bar Items
        let invisibleBottomBar = SKSpriteNode(color: .white, width: self.frame.width, height: self.frame.width/8+40, anchorPoint: CGPoint(x:0,y:0), position: CGPoint(x:0,y:0), zPosition: 0, alpha: 1)
        self.addChild(invisibleBottomBar)
        
        let resetLabel = SKLabelNode(position: CGPoint(x:10,y:(self.frame.width/8+40)/2), zPosition: 1, text: "Reset", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 30, verticalAlignmentMode: .center, horizontalAlignmentMode: .left)
        resetLabel.name = "reset"
        self.addChild(resetLabel)
        
        playButton = SKSpriteNode(imageName: "play", width: self.frame.width/6, height: self.frame.width/6, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:(self.frame.width/8+40)/2), zPosition: 1, alpha: 1)
        playButton.name = "play"
        self.addChild(playButton)
        
        testingLabel = SKLabelNode(position: CGPoint(x:self.frame.width-10,y:(self.frame.width/8+40)/2), zPosition: 1, text: "Test: OFF", fontColor: .lightGray, fontName: "Antipasto Pro", fontSize: 30, verticalAlignmentMode: .center, horizontalAlignmentMode: .right)
        testingLabel.name = "test"
        testingLabel.alpha = 0
        self.addChild(testingLabel)
        
        let nonLinearizable = SKSpriteNode(color: ThemeColor.darkPurple, width: self.frame.width/2, height: self.frame.width/5, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:-1000), zPosition: 0, alpha: 1)
        nonLinearizable.name = "nonLinear"
        let nonLinearizableLabel = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: "NonLinearizable", fontColor: .white, fontName: "Antipasto Pro", fontSize: 25, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        nonLinearizable.addChild(nonLinearizableLabel)
        self.addChild(nonLinearizable)
        
        //Prepare Default Weights and Biases
        (weights,biases) = NeuralNet.setDefaultWeightsAndBiases(numInputs: 2, numOutputs: 7)
        
        //Network Animation
        networkAnimation = NetworkAnimation(myScene: self, position: CGPoint(x:self.frame.width,y:self.frame.width/8+40), weights: weights, biases: biases)
        networkAnimation.update(weights: weights, biases: biases)
        self.addChild(networkAnimation)
    }
    
    @objc func swipe(_ swipe:UISwipeGestureRecognizer){
        
        var isAllUntoggled = true
        for pattern in patternsBar.patterns{
            if pattern.isToggled{
                isAllUntoggled = false
            }
        }
        
        if swipe.direction == .left && currentView == 0 && isAllUntoggled  && !isTraining && !isThinking && !isDecisionBoundaryUp{//Go to Right Screen
            currentView = 1
            for s in self.children{
                if s.name == "bar" || s.name == "trainingSpace" || s.name == "loading" || s.name == "nonLinear" || s.name == "line" || s.name == "point" || s.name == "network"{
                    let move = SKAction.moveBy(x: -self.frame.width, y: 0, duration: 0.2)
                    s.run(move)
                }
            }
        }
        if swipe.direction == .right && currentView == 1 && isAllUntoggled{//Go to Left Screen
            currentView = 0
            for s in self.children{
                if s.name == "bar" || s.name == "trainingSpace" || s.name == "loading" || s.name == "nonLinear" || s.name == "line" || s.name == "point" || s.name == "network"{
                    let move = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.2)
                    s.run(move)
                }
            }
        }
    }
    
    @objc func perceptronIterate(){
        (weights,biases,e) = NeuralNet.perceptronIteration(testInput: [trainingPoints[currentPointIndex].normX,trainingPoints[currentPointIndex].normY], testClass: NeuralNet.patternTypeToPattern(patternType:trainingPoints[currentPointIndex].patternType,patterns: patternsBar.patterns), weights: weights, bias: biases)
        
        for rowIndex in 0..<weights.count{
            var yIntercept = CGPoint(x:0,y:-biases[rowIndex]/weights[rowIndex][1])
            
            let slope = -weights[rowIndex][0]/weights[rowIndex][1]
            var endPoint = CGPoint(x:self.frame.width,y:-biases[rowIndex]/weights[rowIndex][1]+self.frame.width*slope)
            
            let path = CGMutablePath()
            path.move(to: yIntercept)
            path.addLine(to: endPoint)
            path.addLine(to: CGPoint(x:self.frame.width,y:self.frame.height))
            path.addLine(to: CGPoint(x:0,y:self.frame.height))
            path.addLine(to:yIntercept)
            
            let moveLine = SKAction.run({
                self.decisionBoundaries[rowIndex].path = path
            })
            self.run(moveLine)
            
            if isFirstTimeRunningSet{
                let shape = SKShapeNode()
                shape.path = path
                shape.name = "line"
                shape.strokeColor = .lightGray
                shape.lineWidth = 2
                shape.zPosition = -1
                decisionBoundaries.append(shape)
                self.addChild(shape)
            }
        }
        isFirstTimeRunningSet = false
        
        for rowIndex in 0..<decisionBoundaries.count{
            var yIntercept = -biases[rowIndex]/weights[rowIndex][1]
            let slope = -weights[rowIndex][0]/weights[rowIndex][1]
            
            if yIntercept < 0.0 && slope < 0.0{
                decisionBoundaries[rowIndex].fillColor = .clear
            }else{
                decisionBoundaries[rowIndex].fillColor = UIColor(red:150/255,green:150/255,blue:150/255,alpha:CGFloat(arc4random_uniform(75)+25)/150)
                decisionBoundaries[rowIndex].alpha = 0.5
            }
        }
    
        networkAnimation.update(weights: weights, biases: biases)
        
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
                finishedTraining = true
                playButton.alpha = 0
                for s in self.children{
                    if s.name == "play"{
                        s.removeAllActions()
                        let sprite = s as! SKSpriteNode
                        sprite.texture = SKTexture(imageNamed:"play")
                    }
                }
                
            }else{
               
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
                    if sprite.name == "bar" && !isTesting{
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
                    
                    if sprite.name == "bar" && isTesting && !isTestingLabelUp{
                        isTestingLabelUp = true
                        let turnOffNotice = SKSpriteNode(color: ThemeColor.darkPurple, width: self.frame.width/2, height: 1.5*self.frame.width/5, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:-1000), zPosition: 3, alpha: 1)
                        turnOffNotice.name = "nonLinear"
                        let turnOffNoticeLabel = SKLabelNode(position: CGPoint(x:0,y:self.frame.width/17), zPosition: 1, text: "Turn Testing OFF", fontColor: .white, fontName: "Antipasto Pro", fontSize: 22, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
                        let turnOffNoticeLabel2 = SKLabelNode(position: CGPoint(x:0,y:-self.frame.width/17), zPosition: 1, text: "To Place Points", fontColor: .white, fontName: "Antipasto Pro", fontSize: 22, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
                        turnOffNotice.addChild(turnOffNoticeLabel)
                        turnOffNotice.addChild(turnOffNoticeLabel2)
                        self.addChild(turnOffNotice)
                        
                        let moveUp = SKAction.moveTo(y: self.frame.height/2, duration: 0.2)
                        let wait =  SKAction.wait(forDuration: 2)
                        let moveDown = SKAction.moveTo(y: -1000, duration: 0.2)
                        let remove  = SKAction.removeFromParent()
                        let deTrue = SKAction.run({
                            self.isTestingLabelUp = false
                        })
                        let seq = SKAction.sequence([moveUp,wait,moveDown,remove,deTrue])
                        turnOffNotice.run(seq)
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
                        decisionBoundaries = []
                        numDecisionBoundaries = 0
                        testingLabel.alpha = 0
                        isTesting = false
                        playButton.alpha = 1
                        testingLabel.fontColor = .lightGray
                        testingLabel.text = "Test: OFF"
                        (weights,biases) = NeuralNet.setDefaultWeightsAndBiases(numInputs: 2, numOutputs: 7)
                        networkAnimation.update(weights: weights, biases: biases)
                    }
                    
                    if sprite.name == "play" && !isTraining && !isDecisionBoundaryUp && !isThinking && trainingPoints.count > 0 && placedPatterns.count > 1 && !finishedTraining{
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
                        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.perceptronIterate), userInfo: nil, repeats: true)
                    }
                    
                    if sprite.name == "test" && !isTraining && !isDecisionBoundaryUp && !isThinking && trainingPoints.count > 0 && placedPatterns.count > 1 && finishedTraining{
                        if !isTesting{
                            isTesting = true
                            testingLabel.fontColor = ThemeColor.darkPurple
                            testingLabel.text = "Test: ON"
                            let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
                            for pattern in patternsBar.patterns{
                                if pattern.isToggled{
                                    pattern.isToggled = false
                                    for spritePattern in patternsBar.children{
                                        if spritePattern.name == pattern.name{
                                            spritePattern.run(moveUp)
                                        }
                                    }
                                }
                            }
                        }else{
                            isTesting = false
                            testingLabel.fontColor = .lightGray
                            testingLabel.text = "Test: OFF"
                        }
                    }
                    
                    if sprite.name == "trainingSpace" && isTesting{
                        let classification = NeuralNet.classify(x: touch.location(in: self).x, y: touch.location(in: self).y, weights: weights, biases: biases)
                        var newPs:[Pattern] = []
                        for name in placedPatterns{
                            for newP in patternsBar.patterns{
                                if newP.name == name{
                                    newPs.append(newP)
                                }
                            }
                        }
                        let moveUp = SKAction.moveTo(y: self.frame.height/2, duration: 0.2)
                        let wait =  SKAction.wait(forDuration: 2)
                        let remove  = SKAction.removeFromParent()
                        let seq = SKAction.sequence([moveUp,wait,remove])
                        for c in self.children{
                            if c.name == "classificationLabel"{
                                c.removeFromParent()
                            }
                        }
                        if let cPattern = NeuralNet.outVectorToPattern(vector: classification, patterns: newPs, numBoundaries: numDecisionBoundaries){
                            let classLabel = SKSpriteNode(color: cPattern.color, width: self.frame.width/2, height: self.frame.width/5, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:-1000), zPosition: 0, alpha: 1)
                            let classLabelLabel = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: cPattern.name, fontColor: .white, fontName: "ArialRoundedMTBold", fontSize: 25, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
                            classLabel.addChild(classLabelLabel)
                            classLabel.name = "classificationLabel"
                            self.addChild(classLabel)
                            classLabel.run(seq)
                        }else{
                            let unClassified = SKSpriteNode(color: ThemeColor.darkPurple, width: self.frame.width/2, height: self.frame.width/5, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/2,y:-1000), zPosition: 0, alpha: 1)
                            let unClassifiedLabel = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: "Unclassified", fontColor: .white, fontName: "Antipasto Pro", fontSize: 25, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
                            unClassified.addChild(unClassifiedLabel)
                            unClassified.name = "classificationLabel"
                            self.addChild(unClassified)
                            unClassified.run(seq)
                        }
                        
                    }
                    
                    if sprite.name == "trainingSpace" && !isTesting{
                        for p in patternsBar.patterns{
                            if p.isToggled && !isDecisionBoundaryUp && !isThinking && !isTraining{
                                let point = TrainingPoint(position: touch.location(in: self), pattern: p, myScene: self)
                                point.name = "point"
                                
                                let loadingOnAction = SKAction.run {
                                    self.isThinking = true
                                    self.loading.alpha = 1
                                }
                                
                                let thinkingAction = SKAction.run {
                                    if let boundaryCountDelta = NeuralNet.addTrainingPoint(point:point,placedPatterns: self.placedPatterns,numDecisionBoundaries:self.numDecisionBoundaries,trainingPoints:self.trainingPoints,patternBar:self.patternsBar,weights:self.weights,biases:self.biases){
                                        self.numDecisionBoundaries+=boundaryCountDelta
                                        print("Bounds: "+String(self.numDecisionBoundaries))
                                        
                                        self.isThinking = false
                                        self.loading.alpha = 0
                                        
                                        
                                        self.trainingPoints.append(point)
                                        self.addChild(point)
                                        
                                        self.isTesting = false
                                        self.testingLabel.fontColor = .lightGray
                                        self.testingLabel.text = "Test: OFF"
                                        self.finishedTraining = false
                                        self.playButton.alpha = 1
                                        
                                        for pp in self.patternsBar.patterns{
                                            print(pp.outputVector)
                                        }
                                        print()
                                        
                                        var hasBeenPlaced = false
                                        for p in self.placedPatterns{//Check if p was in placed patterns
                                            if p == point.patternType{
                                                hasBeenPlaced = true
                                            }
                                        }
                                        
                                        if !hasBeenPlaced{//Add new pattern if pattern hasn't been placed before
                                            self.placedPatterns.append(p.name)
                                        }
                                        (self.weights,self.biases) = NeuralNet.train(points: self.trainingPoints, patternBar: self.patternsBar.patterns, weights: self.weights, biases: self.biases)!
                                    }else{
                                        //Nonlinearizable
                                        self.isThinking = false
                                        
                                        self.loading.alpha = 0
                                        
                                        for s in self.children{
                                            if s.name == "nonLinear"{
                                                self.isDecisionBoundaryUp = true
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
                                }
                                
                                let seq = SKAction.sequence([loadingOnAction,thinkingAction])
                                self.run(seq)
                                
                            }
                        }
                    }
                    
                    
                    
                }
                
            }
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if trainingPoints.count > 0 && placedPatterns.count > 1 && finishedTraining{
            testingLabel.alpha = 1
        }else{
            testingLabel.alpha = 0
        }
    }
}


