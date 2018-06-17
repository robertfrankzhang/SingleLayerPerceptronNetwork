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
    
    static func hardLimit(array:[CGFloat])->[Int]{
        var v:[Int] = []
        for x in array{
            if x >= 0{
                v.append(1)
            }else{
                v.append(0)
            }
        }
        return v
    }
    
    static func matrixProduct(a:[[CGFloat]],b:[CGFloat])->[CGFloat]{
        var v:[CGFloat] = []
        for weightRow in a{
            var sum:CGFloat = 0
            for weight in weightRow{
                for input in b{
                    sum+=weight*input
                }
            }
            v.append(sum)
        }
        return v
    }
    
    static func matrixProduct(a:[Int],b:[CGFloat])->[[CGFloat]]{
        var c:[[CGFloat]] = []
        for e in a{
            var row:[CGFloat] = []
            for i in b{
                row.append(CGFloat(e)*i)
            }
            c.append(row)
        }
        return c
    }
    
    static func matrix1DAddition(a:[CGFloat],b:[CGFloat])->[CGFloat]{
        var c:[CGFloat] = []
        for i in 0..<a.count{
            c.append(a[i]+b[i])
        }
        return c
    }
    
    static func matrix1DAddition(a:[CGFloat],b:[Int])->[CGFloat]{
        var c:[CGFloat] = []
        for i in 0..<a.count{
            c.append(a[i]+CGFloat(b[i]))
        }
        return c
    }
    
    static func matrix2DAddition(a:[[CGFloat]],b:[[CGFloat]])->[[CGFloat]]{
        var v:[[CGFloat]] = []
        for i in 0..<a.count{
            var vRow:[CGFloat] = []
            for y in 0..<a[i].count{
                vRow.append(a[i][y]+b[i][y])
            }
            v.append(vRow)
        }
        return v
    }

    static func matrix1DSubtraction(a:[Int],b:[Int])->[Int]{
        var c:[Int] = []
        for i in 0..<a.count{
            c.append(a[i]-b[i])
        }
        return c
    }
    
    
    static func perceptronIteration(testInput:[CGFloat],testClass:[Int],weights:[[CGFloat]],bias:[CGFloat])->(w:[[CGFloat]],b:[CGFloat],e:[Int]){
        let a = hardLimit(array: matrix1DAddition(a:matrixProduct(a:weights,b:testInput),b:bias))
        let e = matrix1DSubtraction(a: testClass, b: a)
        let newWeights = matrix2DAddition(a: weights,b: matrixProduct(a: e, b: testInput))
        let newBias = matrix1DAddition(a: bias, b: e)
        return (newWeights,newBias,e)
    }
    
    static func train(points:[TrainingPoint],patternBar:[Pattern],weights:[[CGFloat]],biases:[CGFloat])->(weights:[[CGFloat]],biases:[CGFloat])?{
        //loop until upper perceptron bound. Fix bound at 1000 for now
        var counterLoop = 0
        var w = weights
        var b = biases
        var e:[Int]
        var returnNil = false
        let upperBound = 1000
        
        while counterLoop < upperBound{
            var counter = 0
            for x in 0..<points.count{
                (w,b,e) = perceptronIteration(testInput: [points[x].normX,points[x].normY], testClass: patternTypeToPattern(patternType:points[x].patternType,patterns: patternBar), weights: w, bias: b)
            
                var counter2 = 0
                for y in e{
                    if y == 0{
                        counter2+=1
                    }
                }
                if counter2 == e.count{
                    counter+=1
                }
            }
            if counter == points.count{
                break
            }
            
            counterLoop+=1
            if counterLoop == upperBound{
                returnNil = true
            }
        }
        if returnNil{
            return nil
        }else{
            return (w,b)
        }
        
    }
    
    static func addTrainingPoint(point:TrainingPoint,placedPatterns:[String],numDecisionBoundaries:Int,trainingPoints:[TrainingPoint],patternBar:PatternsBar,weights:[[CGFloat]],biases:[CGFloat])->Int?{//return nil if nonlinearizable, else return #decisionBoundaries after adding point
        if wasPatternBeenUsedBefore(point: point, placedPatterns: placedPatterns){//If old Pattern
            //First see if already used vectors work
            if let (_,_) = train(points: trainingPoints+[point], patternBar: patternBar.patterns,weights: weights,biases: biases){
                return 0
            }
            
            //If not, add decision boundaries iterate through all end values
            let endPossibilities = Int(truncating: pow(2,placedPatterns.count) as NSDecimalNumber)
            for decimalTryEndPatterns in 0..<endPossibilities{
                let endVector = decimalToOutputVector(num: decimalTryEndPatterns, vectorLength: placedPatterns.count)
                var placedPatternVectors:[[Int]] = []
                for pattern in placedPatterns{
                    placedPatternVectors.append(patternTypeToPattern(patternType: pattern, patterns: patternBar.patterns))
                }
                var counter=0
                for i in 0..<placedPatternVectors.count{
                    placedPatternVectors[i][numDecisionBoundaries] = endVector[counter]
                    let somePattern = outVectorToPattern(vector: placedPatternVectors[i], patterns: patternBar.patterns, numBoundaries: numDecisionBoundaries)!
                    patternBar.patterns[findPatternIndex(patternType: somePattern.name, patterns: patternBar.patterns)].outputVector = placedPatternVectors[i]
                    counter+=1
                }
                
                if let (_,_) = train(points:trainingPoints+[point],patternBar: patternBar.patterns,weights: weights,biases: biases){
                    return 1
                }
            }
            return nil
            
        }else{//If new Pattern
            //First see if new pattern works without adding new decisionBoundaries
            let numPossibilities = Int(truncating: pow(2,numDecisionBoundaries) as NSDecimalNumber)
            for decimalTry in 0..<numPossibilities{
                let outputVector = decimalToOutputVector(num: decimalTry, vectorLength: patternBar.patterns.count-1)
                if !patternTypesToPatterns(patternTypes: placedPatterns, patterns: patternBar.patterns).contains(where: {$0 == outputVector}){//If output vector isn't in the placed vectors
                    patternBar.patterns[findPatternIndex(patternType: point.patternType, patterns: patternBar.patterns)].outputVector = outputVector
                    if let (_,_) = train(points:trainingPoints+[point],patternBar: patternBar.patterns,weights: weights,biases: biases){
                        return 0
                    }
                }
            }
            
            //If new pattern doesn't work without adding new decision Boundaries
            let numPossibilitiesPlus = Int(truncating: pow(2,numDecisionBoundaries+1) as NSDecimalNumber)
            let endPossibilities = Int(truncating: pow(2,placedPatterns.count) as NSDecimalNumber)
            
            for decimalTryNewPattern in 0..<numPossibilitiesPlus{
                for decimalTryEndPatterns in 0..<endPossibilities{
                    let outputVector = decimalToOutputVector(num: decimalTryNewPattern, vectorLength: patternBar.patterns.count-1)
                    patternBar.patterns[findPatternIndex(patternType: point.patternType, patterns: patternBar.patterns)].outputVector = outputVector
                    
                    let endVector = decimalToOutputVector(num: decimalTryEndPatterns, vectorLength: placedPatterns.count)
                    var placedPatternVectors:[[Int]] = []
                    for pattern in placedPatterns{
                        placedPatternVectors.append(patternTypeToPattern(patternType: pattern, patterns: patternBar.patterns))
                    }
                    var counter=0
                    for i in 0..<placedPatternVectors.count{
                        placedPatternVectors[i][numDecisionBoundaries] = endVector[counter]
                        let somePattern = outVectorToPattern(vector: placedPatternVectors[i], patterns: patternBar.patterns, numBoundaries: numDecisionBoundaries)!
                        patternBar.patterns[findPatternIndex(patternType: somePattern.name, patterns: patternBar.patterns)].outputVector = placedPatternVectors[i]
                        counter+=1
                    }
                    
                    if let (_,_) = train(points:trainingPoints+[point],patternBar: patternBar.patterns,weights: weights,biases: biases){
                        return 1
                    }
                    
                }
            }
            return nil
        }
    }
    
    static func findPatternIndex(patternType:String,patterns:[Pattern])->Int{
        for index in 0..<patterns.count{
            if patterns[index].name == patternType{
                return index
            }
        }
        return -1
    }
    
    static func outVectorToPattern(vector:[Int],patterns:[Pattern],numBoundaries:Int)->Pattern?{
        
        for pattern in patterns{
            var counter =  0
            for i in 0..<numBoundaries{
                if vector[i] == pattern.outputVector[i]{
                    counter+=1
                }
            }
            if counter == numBoundaries{
                return pattern
            }
        }
        return nil
    }
    
    static func patternTypeToPattern(patternType:String,patterns:[Pattern])->[Int]{
        for pattern in patterns{
            if pattern.name == patternType{
                return pattern.outputVector
            }
        }
        return []
    }
    
    static func patternTypesToPatterns(patternTypes:[String],patterns:[Pattern])->[[Int]]{
        var vectors:[[Int]] = []
        for patternType in patternTypes{
            let vector = patternTypeToPattern(patternType: patternType, patterns: patterns)
            vectors.append(vector)
        }
        return vectors
    }
    
    static func decimalToOutputVector(num:Int,vectorLength:Int)->[Int]{//Convects a number to an output vector
        let str = pad(string: String(num,radix:2),toSize: vectorLength)
        var output:[Int] = []
        for s in str{
            output.append(Int(String(s))!)
        }
        return output
    }
    
    static func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.count) {
            padded = padded + "0"
        }
        return padded
    }
    
    static func wasPatternBeenUsedBefore(point:TrainingPoint,placedPatterns:[String])->Bool{
        var hasBeenPlaced = false
        for pattern in placedPatterns{
            if pattern == point.patternType{
                hasBeenPlaced = true
            }
        }
        return hasBeenPlaced
    }
    
    
}
