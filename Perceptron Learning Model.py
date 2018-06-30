
import numpy as np
import matplotlib.pyplot as plt

inputD = int(input("# of inputs?"))
inputC = int(input("# of outputs?"))

def enterTrainingVector():
    trainingInputVector = np.array([])
    for x in range(0,inputD):
        i = float(input("Enter Input Vector Element"))
        trainingInputVector = np.append(trainingInputVector,i)
        
    trainingOutputVector = np.array([])
    for x in range(0,inputC):
        i = float(input("Enter Classification Vector Element"))
        trainingOutputVector = np.append(trainingOutputVector,i)
        
    return trainingInputVector,trainingOutputVector

def getTrainingSet():
    counter = 0
    while True:
        if counter == 0:
            input1,classes1 = enterTrainingVector()
            inputs = np.array([input1])
            classes = np.array([classes1])
            counter+=1
        else:
            inputs1,classes1 = enterTrainingVector()
            classes = np.concatenate((classes,[classes1]),axis=0)
            inputs = np.concatenate((inputs,[inputs1]),axis=0)
        option = int(input("Continue (0), Done (1)"))
        if option == 1:
            break
    return inputs,classes

def hardLimit(num):
    print(num)
    v = np.array([])
    for x in num:
        if x >= 0:
            v = np.append(v,1)
        else:
            v = np.append(v,0)
    return v

def perceptronIteration(testInput,testClass,weights,bias):
    print(weights)
    a = hardLimit(weights.dot(testInput)+bias)
    e = testClass-a

    bias = bias+e
    e = e*0.00001
    weights = weights+e.reshape((e.size,1)).dot(testInput.reshape((1,testInput.size)))
    
    return weights,bias,e    

def train(inputs,classes):
    isTrained = False
    weights = np.zeros((inputC,inputD))
    bias = np.zeros((inputC))

    tempLoop = 0
    while not(isTrained):
        counter = 0
        for x in range(inputs.shape[0]):
            weights,bias,e = perceptronIteration(inputs[x],classes[x],weights,bias)
            counter2 = 0
            
            for x in e:               
                if x == 0:
                    counter2 += 1
            if counter2 == e.size:
                counter+=1
        if counter == inputs.shape[0]:
            break

        tempLoop+=1
    print(tempLoop)
    return weights,bias
    
def main():
    inputs,classes = getTrainingSet()
    weights,bias = train(inputs,classes)
    
    print(weights)
    print(bias)


main()


    
