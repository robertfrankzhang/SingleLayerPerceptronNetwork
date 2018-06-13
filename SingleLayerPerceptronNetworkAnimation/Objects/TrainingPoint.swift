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
    
    //2 Input Values
    var normX:CGFloat
    var normY:CGFloat
    
    //7 Output Values
    var outputVector = [0,0,0,0,0,0,0]
    
    init(position:CGPoint,color:UIColor,myScene:SKScene){
        self.myScene = myScene
        normX = position.x/myScene.frame.width
        normY  = position.y/myScene.frame.height
        super.init(texture: SKTexture(imageNamed: "circle"), color: color, size: CGSize(width:10,height:10))
        self.position = position
        self.colorBlendFactor = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
