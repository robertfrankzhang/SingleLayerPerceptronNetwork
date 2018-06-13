//
//  Info.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import SpriteKit
import GameplayKit

class InfoScene: SKScene {
    
    var progressBar = ProgressBar()
    var slideNum = 0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        //Top Bar
        let backButton = SKSpriteNode(imageName: "back", width: self.frame.width/8, height: self.frame.width/8, anchorPoint: CGPoint(x:0,y:1), position: CGPoint(x:10,y:self.frame.height-30), zPosition: 1, alpha: 1)
        backButton.name = "back"
        self.addChild(backButton)
        
        let titleLabel = SKLabelNode(position: CGPoint(x:self.frame.width/2,y:self.frame.height-30-self.frame.width/16), zPosition: 1, text: "About", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 30, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        self.addChild(titleLabel)
        
        //Content
        let slideOne = SKLabelNode(position: CGPoint(x:self.frame.width*0.1,y:self.frame.height-30-self.frame.width/16-80), zPosition: 1, text: "This app demonstrates the training of a single layer feedforward perceptron network. This is the most basic type of neural network, as most neural networks have many layers and even billion of neurons (plus thousands of input neurons), while this network has one hidden layer and two input neurons. Single Layer NNs can only classify linearly separable patterns. However, the fundamental concepts it uses to train is analogous to deeper networks", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .left)
        slideOne.name = "slide"
        self.addChild(MultilineLabelNode.create(label: slideOne, width: self.frame.width*0.8, lineSpacing: 5, backgroundColor: .clear,ID:"slide"))
        
        let slideTwo = SKLabelNode(position: CGPoint(x:self.frame.width*0.1+self.frame.width,y:self.frame.height-30-self.frame.width/16-80), zPosition: 1, text: "This perceptron network uses the fundamental Perceptron Learning Rule to train. The Perceptron Learning Rule uses a straightforward, procedural, mathematical method to adjust the weight matrix and bias vector of a NN so that it can correctly classify patterns. This program specifically finds a weight matrix and bias vector that correctly classifies linearly separable colored dots on a Euclidean grid", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .left)
        slideTwo.name = "slide"
        self.addChild(MultilineLabelNode.create(label: slideTwo, width: self.frame.width*0.8, lineSpacing: 5, backgroundColor: .clear,ID:"slide"))
        
        let slideThree = SKLabelNode(position: CGPoint(x:self.frame.width*0.1+2*self.frame.width,y:self.frame.height-30-self.frame.width/16-80), zPosition: 1, text: "You can place color dots by selecting colors from the colored squares on the top color bar. When you tap, the dot that is placed will be of the selected color. The app will ensure that all of the dots you place will be linearly separable. You can also reset the entire grid by tapping \"Reset\". Once you are ready, press the play button to begin training", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .left)
        self.addChild(MultilineLabelNode.create(label: slideThree, width: self.frame.width*0.8, lineSpacing: 5, backgroundColor: .clear,ID:"slide"))
        
        let slideFour = SKLabelNode(position: CGPoint(x:self.frame.width*0.1+3*self.frame.width,y:self.frame.height-30-self.frame.width/16-80), zPosition: 1, text: "As the model trains, you can swipe between the neural network view and the Euclidean view. After training, you can keep placing dots. If you press play again, the network will retrain to reoptimize the weights and biases to fit the new dots. You can also go into testing mode, where you place nonpatterned dots, and the network tells you which pattern it belongs to. Finally, you can view the weights and biases of the network by tapping \"Weights\"", fontColor: ThemeColor.darkPurple, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .left)
        self.addChild(MultilineLabelNode.create(label: slideFour, width: self.frame.width*0.8, lineSpacing: 5, backgroundColor: .clear,ID:"slide"))
        
        //Progress Bar
        progressBar = ProgressBar(myScene: self,totalLevels:4,position:CGPoint(x:self.frame.width/2,y:self.frame.height*0.1))
        self.addChild(progressBar)
        
        let swipeRightRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        swipeRightRecognizer.direction = .right
        self.view?.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        swipeLeftRecognizer.direction = .left
        self.view?.addGestureRecognizer(swipeLeftRecognizer)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            for sprite in self.children{
                if sprite.contains(touch.location(in: self)){
                    if sprite.name == "back"{
                        let scene = HomeScene(size: self.size)
                        view?.presentScene(scene, transition:SKTransition.push(with: .right, duration: 0.3))
                    }
                }
            }
        }
    }
    
    @objc func swiped(_ swipe:UISwipeGestureRecognizer){
        progressBar.move(swipe: swipe)
        if swipe.direction == .left && slideNum < 3{
            slideNum+=1
            for child in self.children{
                if child.name == "slide"{
                    let moveRight = SKAction.moveBy(x: -self.frame.width, y: 0, duration: 0.1)
                    child.run(moveRight)
                }
            }
        }
        if swipe.direction == .right && slideNum > 0{
            slideNum-=1
            for child in self.children{
                if child.name == "slide"{
                    let moveLeft = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.1)
                    child.run(moveLeft)
                }
            }
        }
    }
    
}

