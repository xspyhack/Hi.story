//
//  BirthdayCardView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class BirthdayCardView: TodayCardView {
    
    private lazy var fireworks: Fireworks = {
        let fireworks = Fireworks()
        fireworks.clipsToBounds = true
        fireworks.layer.cornerRadius = 16.0
        return fireworks
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.hi.birthday
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.alpha = 0.0
        return label
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        fireworks.startAnimating()
        
        delay(12.0) { [weak self] in
            self?.fireworks.stopAnimating()
            
            // show text, background
            UIView.animate(withDuration: 0.35, animations: { 
                self?.backgroundImageView.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, animations: { 
                    self?.textLabel.alpha = 1.0
                })
            })
        }
    }
    
    func stop() {
        fireworks.stopAnimating()
    }
    
    private func setup() {
        
        addSubview(fireworks)
        fireworks.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "fireworks": fireworks
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[fireworks]|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[fireworks]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}
