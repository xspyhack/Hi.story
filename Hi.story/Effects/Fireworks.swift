//
//  Fireworks.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 21/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class Fireworks: UIView {
    
    private var mortor: CAEmitterLayer?
    
    var isAnimating: Bool = false

    func startAnimating() {
        guard !isAnimating else { return }
       
        setup()
        isAnimating = true
    }
    
    func stopAnimating() {
        guard isAnimating else { return }
      
        mortor?.removeFromSuperlayer()
        mortor = nil
        isAnimating = false
    }
    
    func setup() {
        backgroundColor = UIColor.black
        
        //Load the spark image for the particle
        let image = UIImage(named: "spark")
        let img = image?.cgImage
        
        let mortor = CAEmitterLayer()
        mortor.emitterPosition = CGPoint(x: 200, y: 600)
        mortor.renderMode = kCAEmitterLayerAdditive
        
        //Invisible particle representing the rocket before the explosion
        let rocket = CAEmitterCell()
        rocket.emissionLongitude = 3 * CGFloat.pi / 2
        rocket.emissionLatitude = 0
        rocket.lifetime = 1.6
        rocket.birthRate = 1
        rocket.velocity = 400
        rocket.velocityRange = 100
        rocket.yAcceleration = 250
        rocket.emissionRange = CGFloat.pi / 8.0
        rocket.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor
        rocket.redRange = 0.5
        rocket.greenRange = 0.5
        rocket.blueRange = 0.5
        //Name the cell so that it can be animated later using keypath
        rocket.name = "rocket"
        
        //Flare particles emitted from the rocket as it flys
        let flare = CAEmitterCell()
        flare.contents = img
        flare.emissionLongitude = (4 * CGFloat.pi) / 2
        flare.scale = 0.4
        flare.velocity = 100
        flare.birthRate = 45
        flare.lifetime = 1.5
        flare.yAcceleration = 350
        flare.emissionRange = CGFloat.pi / 7
        flare.alphaRange = -0.7
        flare.scaleSpeed = -0.1
        flare.scaleRange = 0.1
        flare.beginTime = 0.01
        flare.duration = 0.7
      
        //The particles that make up the explosion
        let firework = CAEmitterCell()
        firework.contents = img
        firework.birthRate = 9999
        firework.scale = 0.6
        firework.velocity = 130
        firework.lifetime = 2
        firework.alphaSpeed = -0.2
        firework.yAcceleration = -80
        firework.beginTime = 1.5
        firework.duration = 0.1
        firework.emissionRange = 2 * CGFloat.pi
        firework.scaleSpeed = -0.1
        firework.spin = 2
        //Name the cell so that it can be animated later using keypath
        firework.name = "firework"
        
        //preSpark is an invisible particle used to later emit the spark
        let preSpark = CAEmitterCell()
        preSpark.birthRate = 80
        preSpark.velocity = firework.velocity * 0.70
        preSpark.lifetime = 1.7
        preSpark.yAcceleration = firework.yAcceleration * 0.85
        preSpark.beginTime = firework.beginTime - 0.2
        preSpark.emissionRange = firework.emissionRange
        preSpark.greenSpeed = 100
        preSpark.blueSpeed = 100
        preSpark.redSpeed = 100
        //Name the cell so that it can be animated later using keypath
        preSpark.name = "preSpark"
        
        //The 'sparkle' at the end of a firework
        let spark = CAEmitterCell()
        spark.contents = img
        spark.lifetime = 0.05
        spark.yAcceleration = -250
        spark.beginTime = 0.8
        spark.scale = 0.4
        spark.birthRate = 10
        
        preSpark.emitterCells = [spark]
        rocket.emitterCells = [flare, firework, preSpark]
        mortor.emitterCells = [rocket]
        layer.addSublayer(mortor)
    
        self.mortor = mortor
        
        //Force the view to update
        setNeedsDisplay()
    }
}
