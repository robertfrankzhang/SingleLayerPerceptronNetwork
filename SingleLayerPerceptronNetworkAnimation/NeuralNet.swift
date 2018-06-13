//
//  NeuralNet.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/13/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class NeuralNet{
    static func setDefaultWeightsAndBiases(numInputs:Int,numOutputs:Int)->(weightMatrix:[[CGFloat]],biasVector:[CGFloat]){
        //Create Weight Matrix of Zeros
        var weightMatrix:[[CGFloat]] = []
        for _ in 0..<numOutputs{
            var weightRow:[CGFloat] = []
            for _ in 0..<numInputs{
                weightRow.append(0)
            }
            weightMatrix.append(weightRow)
        }
        
        //Create Bias Vector of Zeros
        var biasVector:[CGFloat] = []
        for _ in 0..<numOutputs{
            biasVector.append(0)
        }
        
        return (weightMatrix,biasVector)
    }
}
