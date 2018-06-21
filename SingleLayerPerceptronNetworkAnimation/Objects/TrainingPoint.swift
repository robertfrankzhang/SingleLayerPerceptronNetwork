//
//  TrainingPoint.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/13/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class TrainingPoint:SKSpriteNode{
    
    var myScene:SKScene
    
    var patternType:String
    
    //2 Input Values
    var normX:CGFloat
    var normY:CGFloat
    
    //The Output Values are stored in the Patterns Array in the PatternsBar Object
    
    init(position:CGPoint,pattern:Pattern,myScene:SKScene){
        self.myScene = myScene
        self.patternType = pattern.name
        normX = position.x
        normY  = position.y
        super.init(texture: SKTexture(imageNamed: "circle"), color: pattern.color, size: CGSize(width:10,height:10))
        self.position = position
        self.zPosition = -1
        self.colorBlendFactor = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
