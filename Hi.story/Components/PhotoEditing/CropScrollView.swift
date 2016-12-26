//
//  CropScrollView.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 01/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class CropScrollView: UIScrollView {

    var touchesBegan: (() -> Void)?
    var touchesCancelled: (() -> Void)?
    var touchesEnded: (() -> Void)?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBegan?()
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelled?()
        
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded?()
        
        super.touchesEnded(touches, with: event)
    }
}
