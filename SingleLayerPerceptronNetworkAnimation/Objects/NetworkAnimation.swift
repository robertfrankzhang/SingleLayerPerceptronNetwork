//
//  NetworkAnimation.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/19/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import SpriteKit

class NetworkAnimation:SKSpriteNode{
    var myScene:SKScene = SKScene()
    var myWeights:[[SKShapeNode]] = []
    var biases:[Neuron] = []
    var x = SKSpriteNode()
    var y = SKSpriteNode()
    
    init(myScene:SKScene,position:CGPoint,weights:[[CGFloat]],biases:[CGFloat]) {
        self.myScene = myScene
        super.init(texture: SKTexture(), color:.white, size: CGSize(width:myScene.frame.width,height:myScene.frame.height-(myScene.frame.width/8*3+80)))
        self.zPosition = 1
        self.name = "network"
        self.position = position
        self.anchorPoint = CGPoint(x:0,y:0)
        
        //Input Neurons
        x = SKSpriteNode(imageName: "circle", width: self.frame.width/6, height: self.frame.width/6, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/4,y:self.frame.height*0.6), zPosition: 1, alpha: 1)
        x.color = ThemeColor.darkPurple
        x.colorBlendFactor = 1
        let xLabel = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: "x", fontColor: .white, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        x.addChild(xLabel)
        self.addChild(x)
        
        y = SKSpriteNode(imageName: "circle", width: self.frame.width/6, height: self.frame.width/6, anchorPoint: CGPoint(x:0.5,y:0.5), position: CGPoint(x:self.frame.width/4,y:self.frame.height*0.4), zPosition: 1, alpha: 1)
        y.color = ThemeColor.darkPurple
        y.colorBlendFactor = 1
        let yLabel = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: "y", fontColor: .white, fontName: "Antipasto Pro", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        y.addChild(yLabel)
        self.addChild(y)
        
        //Output Neurons
        for row in 1...7{
            let neuron = Neuron(myScene: self, bias: biases[row-1], row: row)
            self.biases.append(neuron)
            self.addChild(neuron)
        }
        
        //Weights
        print("WEIGHTS:")
        print(weights)
        print(weights.count)
        print(weights[0].count)
        for weightRowIndex in 0..<weights.count{
            var weightRow:[SKShapeNode] = []
            for weightIndex in 0..<weights[weightRowIndex].count{
                let path = CGMutablePath()
                if weightIndex == 0{
                    path.move(to: x.position)
                }
                if weightIndex == 1{
                    path.move(to: y.position)
                }
                path.addLine(to: self.biases[weightRowIndex].position)
                
                let shape = SKShapeNode()
                shape.path = path
                shape.name = "line"
                shape.strokeColor = ThemeColor.darkPurple
                shape.lineWidth = 4
                shape.zPosition = 1
                self.addChild(shape)
                weightRow.append(shape)
                
            }
            myWeights.append(weightRow)
        }
        
        
    }
    
    init(){
        super.init(texture: SKTexture(), color:.white, size: CGSize(width:myScene.frame.width,height:myScene.frame.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(weights:[[CGFloat]],biases:[CGFloat]){
        var maxAbsWeight:CGFloat = 0
        for weightRowIndex in 0..<weights.count{
            for weightIndex in 0..<weights[weightRowIndex].count{
                if abs(weights[weightRowIndex][weightIndex]) > maxAbsWeight{
                    maxAbsWeight = abs(weights[weightRowIndex][weightIndex])
                }
            }
        }
        
        for weightRowIndex in 0..<weights.count{
            for weightIndex in 0..<weights[weightRowIndex].count{
                myWeights[weightRowIndex][weightIndex].alpha = weights[weightRowIndex][weightIndex]/maxAbsWeight
            }
        }
        
        for neuronIndex in 0..<biases.count{
            self.biases[neuronIndex].update(bias: biases[neuronIndex])
        }
        
    }
}

class Neuron:SKSpriteNode{
    var myScene:SKSpriteNode = SKSpriteNode()
    var bias:CGFloat = 0
    var label:SKLabelNode = SKLabelNode()
    
    init(myScene:SKSpriteNode,bias:CGFloat,row:Int) {
        super.init(texture: SKTexture(imageNamed:"circle"), color:ThemeColor.darkPurple, size: CGSize(width:myScene.frame.width/7,height:myScene.frame.width/7))
        self.myScene = myScene
        self.bias = bias
        self.colorBlendFactor = 1
        self.position = CGPoint(x:myScene.frame.width*0.75,y:myScene.frame.height*(8-CGFloat(row))/8)
        
        label = SKLabelNode(position: CGPoint(x:0,y:0), zPosition: 1, text: String(describing: Int(bias)), fontColor: .white, fontName: "Arial Bold", fontSize: 20, verticalAlignmentMode: .center, horizontalAlignmentMode: .center)
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(bias:CGFloat){
        self.bias = bias
        label.text = String(describing: Int(bias))
    }
}
