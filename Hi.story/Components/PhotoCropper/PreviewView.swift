//
//  PreviewView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class PreviewView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {

        let roundedRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0.0)

        let circlePath = UIBezierPath.init(ovalIn: roundedRect)

        path.append(circlePath)
        path.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.layer.addSublayer(fillLayer)
    }
}
