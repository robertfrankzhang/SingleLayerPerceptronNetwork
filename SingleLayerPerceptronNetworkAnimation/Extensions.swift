//
//  Extensions.swift
//  OutreachProject
//
//  Created by Robert Frank Zhang on 12/24/17.
//  Copyright © 2017 iLaunch. All rights reserved.
//

import SpriteKit

extension SKLabelNode{
    convenience init(position pos:CGPoint,zPosition zPos:CGFloat,text:String,fontColor color:UIColor,fontName:String,fontSize:CGFloat,verticalAlignmentMode vAM:SKLabelVerticalAlignmentMode,horizontalAlignmentMode hAM:SKLabelHorizontalAlignmentMode){
        self.init(fontNamed:fontName)
        self.position = pos
        self.zPosition = zPos
        self.text = text
        self.fontColor = color
        self.fontSize = fontSize
        self.verticalAlignmentMode = vAM
        self.horizontalAlignmentMode = hAM
    }
}

extension SKSpriteNode{
    convenience init(imageName image:String,width:CGFloat,height:CGFloat,anchorPoint:CGPoint,position:CGPoint,zPosition:CGFloat,alpha:CGFloat){
        let texture = SKTexture(imageNamed: image)
        self.init(texture:texture,color:.clear,size:texture.size())
        self.size = CGSize(width:width,height:height)
        self.anchorPoint = anchorPoint
        self.position = position
        self.zPosition = zPosition
        self.alpha = alpha
    }
    
    convenience init(color:UIColor,width:CGFloat,height:CGFloat,anchorPoint:CGPoint,position:CGPoint,zPosition:CGFloat,alpha:CGFloat){
        let texture = SKTexture()
        self.init(texture:texture,color:color,size:CGSize(width:width,height:height))
        self.colorBlendFactor = 1
        self.anchorPoint = anchorPoint
        self.position = position
        self.zPosition = zPosition
        self.alpha = alpha
    }
}

extension UIColor {
    public func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = CGFloat(fRed)
            let iGreen = CGFloat(fGreen)
            let iBlue = CGFloat(fBlue)
            let iAlpha = CGFloat(fAlpha)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

