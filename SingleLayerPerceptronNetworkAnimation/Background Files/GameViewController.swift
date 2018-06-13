//
//  GameViewController.swift
//  SingleLayerPerceptronNetworkAnimation
//
//  Created by Robert Frank Zhang on 6/12/18.
//  Copyright © 2018 RZ. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
            let scene = HomeScene(size: self.view.bounds.size)
            view.presentScene(scene, transition:SKTransition.push(with: .left, duration: 0.3))
            view.ignoresSiblingOrder = true
        }
    }
}
