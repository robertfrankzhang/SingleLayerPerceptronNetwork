//
//  MultilineLabelNode.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class MultilineLabelNode{
    static func create(label:SKLabelNode,width:CGFloat,lineSpacing:CGFloat,backgroundColor:UIColor,ID:String)->SKSpriteNode{
        var words = label.text?.components(separatedBy: " ")
        var lineCounter:CGFloat = 0
        var labels:[SKLabelNode] = []
        var wordCounter:Int = 0
        
        var s:String = ""
        var lagS:String = ""
        while true{
            s+=" "+words![wordCounter]
            let testLabel = SKLabelNode(position: CGPoint(x:0,y:-lineCounter*(lineSpacing+label.frame.height)), zPosition: 1, text: s, fontColor: label.fontColor!, fontName: label.fontName!, fontSize: label.fontSize, verticalAlignmentMode: label.verticalAlignmentMode, horizontalAlignmentMode: label.horizontalAlignmentMode)
            if testLabel.frame.width > width{
                lineCounter+=1
                testLabel.text = lagS
                labels.append(testLabel)
                s = ""
                lagS = ""
            }else{
                lagS+=" "+words![wordCounter]
                wordCounter+=1
            }
            if wordCounter >= words!.count{
                testLabel.text = lagS
                labels.append(testLabel)
                break
            }
        }
        
        let bg = SKSpriteNode(color: backgroundColor, width: width, height: (labels[0].frame.height+lineSpacing)*CGFloat(labels.count), anchorPoint: CGPoint(x:0,y:1), position: label.position, zPosition: 0, alpha: 1)
        bg.name = ID
        for l in labels{
            bg.addChild(l)
        }
        
        return bg
    }
}
