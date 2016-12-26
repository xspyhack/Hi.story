//
//  CropOverlayView.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 01/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

private let overLayerCornerWidth: CGFloat = 20.0

class CropOverlayView: UIView {
    
    /** Hides the interior grid lines, sans animation. */
    private(set) var isGridHidden = false

    /** Add/Remove the interior horizontal grid lines. */
    var showsHorizontalGridLines = true {
        didSet {
            horizontalGridLines.forEach {
                $0.removeFromSuperview()
            }
            
            if showsHorizontalGridLines {
                horizontalGridLines = [createNewLineView(), createNewLineView()]
            } else {
                horizontalGridLines = []
            }
            
            setNeedsDisplay()
        }
    }
    
    /** Add/Remove the interior vertical grid lines. */
    var showsVerticalGridLines = true {
        didSet {
            verticalGridLines.forEach {
                $0.removeFromSuperview()
            }
            
            if showsVerticalGridLines {
                verticalGridLines = [createNewLineView(), createNewLineView()]
            } else {
                verticalGridLines = []
            }
            
            setNeedsDisplay()
        }
    }
    
    // Private 
    private var horizontalGridLines: [UIView] = []
    private var verticalGridLines: [UIView] = []
    
    private var outerLineViews: [UIView] = []   //top, right, bottom, left
    
    private var topLeftLineViews: [UIView] = [] //vertical, horizontal
    private var bottomLeftLineViews: [UIView] = []
    private var bottomRightLineViews: [UIView] = []
    private var topRightLineViews: [UIView] = []
    
    /** Shows and hides the interior grid lines with an optional crossfade animation. */
    func setGridHidden(_ hidden: Bool, animated: Bool) {
        isGridHidden = hidden
        
        let action = {
            
            for lineView in self.horizontalGridLines {
                lineView.alpha = hidden ? 0.0 : 1.0
            }
            
            for lineView in self.verticalGridLines {
                lineView.alpha = hidden ? 0.0 : 1.0
            }
        }
        
        if !animated {
            action()
        } else {
            UIView.animate(withDuration: hidden ? 0.35 : 0.25) {
                action()
            }
        }
    }
    
    // Private method
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        willSet {
            super.frame = newValue
            
            if !outerLineViews.isEmpty {
                layoutLines()
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !outerLineViews.isEmpty {
            layoutLines()
        }
    }
    
    private func setup() {
        
        let newLine: () -> UIView = {
            return self.createNewLineView()
        }
        
        outerLineViews = [newLine(), newLine(), newLine(), newLine()]
        
        topLeftLineViews = [newLine(), newLine()]
        bottomLeftLineViews = [newLine(), newLine()]
        topRightLineViews = [newLine(), newLine()]
        bottomRightLineViews = [newLine(), newLine()]
        
        showsVerticalGridLines = true
        showsHorizontalGridLines = true
    }
    
    private func layoutLines() {
        
        let boundsSize = self.bounds.size
        
        for (index, lineView) in outerLineViews.enumerated() {
            var frame = CGRect.zero
            
            switch index {
            case 0:
                frame = CGRect(x: 0.0, y: -1.0, width: boundsSize.width + 2.0, height: 1.0) // top
            case 1:
                frame = CGRect(x: boundsSize.width, y: 0.0, width: 1.0, height: boundsSize.height) // right
            case 2:
                frame = CGRect(x: -1.0, y: boundsSize.height, width: boundsSize.width + 2.0, height: 1.0) // bottom
            case 3:
                frame = CGRect(x: -1.0, y: 0.0, width: 1.0, height: boundsSize.height + 1.0) // left
            default:
                assertionFailure("outerLineViews must be 0..<4")
            }
            
            lineView.frame = frame
        }
        
        // corner lines
        let cornerLines = [topLeftLineViews, topRightLineViews, bottomRightLineViews, bottomLeftLineViews]
        
        for (index, cornerLine) in cornerLines.enumerated() {
            
            var vertiaclFrame = CGRect.zero
            var horizontalFrame = CGRect.zero
            
            switch index {
            case 0:
                // top left
                vertiaclFrame = CGRect(x: -3.0, y: -3.0, width: 3.0, height: overLayerCornerWidth + 3.0)
                horizontalFrame = CGRect(x: 0.0, y: -3.0, width: overLayerCornerWidth, height: 3.0)
            case 1:
                // top right
                vertiaclFrame = CGRect(x: boundsSize.width, y: -3.0, width: 3.0, height: overLayerCornerWidth + 3.0)
                horizontalFrame = CGRect(x: boundsSize.width - overLayerCornerWidth, y: -3.0, width: overLayerCornerWidth, height: 3.0)
            case 2:
                // bottom righ
                vertiaclFrame = CGRect(x: boundsSize.width, y: boundsSize.height - overLayerCornerWidth, width: 3.0, height: overLayerCornerWidth + 3.0)
                horizontalFrame = CGRect(x: boundsSize.width - overLayerCornerWidth, y: boundsSize.height, width: overLayerCornerWidth, height: 3.0)
            case 3:
                // bottom left
                vertiaclFrame = CGRect(x: -3.0, y: boundsSize.height - overLayerCornerWidth, width: 3.0, height: overLayerCornerWidth)
                horizontalFrame = CGRect(x: -3.0, y: boundsSize.height, width: overLayerCornerWidth + 3.0, height: 3.0)
            default:
                assertionFailure("cornerLines must be 0..<4")
            }
            
            cornerLine[0].frame = vertiaclFrame
            cornerLine[1].frame = horizontalFrame
        }
        
        //grid lines - horizontal
        let thickness: CGFloat = 1.0 / UIScreen.main.scale
        var numberOfLines = horizontalGridLines.count
        var padding: CGFloat = (self.bounds.height - (thickness * CGFloat(numberOfLines))) / CGFloat((numberOfLines + 1))
        for (index, lineView) in horizontalGridLines.enumerated() {
            var frame = CGRect.zero
            frame.size.height = thickness
            frame.size.width = self.bounds.width
            frame.origin.y = (padding * CGFloat(index + 1)) + (thickness * CGFloat(index))
            lineView.frame = frame
        }
        
        //grid lines - vertical
        numberOfLines = verticalGridLines.count
        padding = (self.bounds.width - (thickness * CGFloat(numberOfLines))) / CGFloat(numberOfLines + 1)
        for (index, lineView) in verticalGridLines.enumerated() {
            var frame = CGRect.zero
            frame.size.width = thickness
            frame.size.height = self.bounds.height
            frame.origin.x = (padding * CGFloat(index + 1)) + (thickness * CGFloat(index))
            lineView.frame = frame
        }
    }
    
    private func createNewLineView() -> UIView {
        let newLine = UIView(frame: .zero)
        newLine.backgroundColor = UIColor.white
        self.addSubview(newLine)
        return newLine
    }
}
