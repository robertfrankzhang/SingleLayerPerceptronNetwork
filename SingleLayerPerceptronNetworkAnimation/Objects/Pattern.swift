//
//  Pattern.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Pattern{
    var color:UIColor
    var name:String
    var outputVector:[Int] = []
    var isToggled = false
    
    init(color:UIColor,name:String) {
        self.color = color
        self.name = name
    }
}
