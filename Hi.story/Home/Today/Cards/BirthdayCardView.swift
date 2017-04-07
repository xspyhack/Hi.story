//
//  BirthdayCardView.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/03/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Gifu

final class BirthdayCardView: TodayCardView {
    
    private struct Constant {
        static let avatarSize = CGSize(width: 40.0, height: 40.0)
        static let hatSize = CGSize(width: 84.0, height: 84.0)
    }
    
    private lazy var fireworks: Fireworks = {
        let fireworks = Fireworks()
        fireworks.clipsToBounds = true
        fireworks.layer.cornerRadius = 16.0
        return fireworks
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.layer.cornerRadius = 12.0
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.layer.cornerRadius = 12.0
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private lazy var cakeImageView: GIFImageView = {
        let imageView = GIFImageView()
        imageView.animate(withGIFNamed: "birthday")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private(set) lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width)
        return imageView
    }()
    
    private(set) lazy var hatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.hi.hat
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "ChalkboardSE-Regular", size: 20.0)
        label.text = "~ HAPPY BIRTHDAY ~"
        label.textColor = UIColor(hex: "#C01329")
        return label
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            gradientView.hi.apply([UIColor.white, UIColor(hex: "#D6E4EC")], orientation: .vertical)
            addMotionEffect()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientView.hi.gradient?.frame = CGRect(origin: .zero, size: CGSize(width: backgroundView.bounds.width, height: backgroundView.bounds.height * 0.4))
    }
    
    func start() {
        fireworks.startAnimating()
        
        delay(12.0) { [weak self] in
            self?.fireworks.stopAnimating()
            
            // show text, background
            UIView.animate(withDuration: 0.35, animations: { 
                self?.backgroundView.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, animations: { 
                    self?.contentView.alpha = 1.0
                })
            })
        }
    }
    
    func stop() {
        fireworks.stopAnimating()
    }
    
    private func setup() {
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
        addSubview(fireworks)
        fireworks.translatesAutoresizingMaskIntoConstraints = false
        
        do {
            addSubview(backgroundView)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            backgroundView.addSubview(gradientView)
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            
            backgroundView.addSubview(cakeImageView)
            cakeImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        do {
            addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(avatarImageView)
            avatarImageView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(hatImageView)
            hatImageView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        let views: [String: Any] = [
            "fireworks": fireworks,
            "backgroundView": backgroundView,
            "contentView": contentView,
            "gradientView": gradientView,
            "cakeImageView": cakeImageView,
            "avatarImageView": avatarImageView,
            "hatImageView": hatImageView,
            "textLabel": textLabel,
        ]
        
        func constraints(_ view: UIView) {
           
            let views: [String: Any] = [
                "view": view,
            ]
            
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
            let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(h)
            NSLayoutConstraint.activate(v)
        }
        
        constraints(fireworks)
        constraints(backgroundView)
        constraints(contentView)
        
        let backgroundViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[gradientView][cakeImageView]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        NSLayoutConstraint.activate(backgroundViewV)
        
        let backgroundViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[gradientView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(backgroundViewH)
        
        NSLayoutConstraint(item: gradientView, attribute: .height, relatedBy: .equal, toItem: backgroundView, attribute: .height, multiplier: 0.4, constant: 0.0).isActive = true
        
        let avatarV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-60-[avatarImageView(40)]", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(avatarV)
        avatarImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        avatarImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        hatImageView.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor).isActive = true
        hatImageView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        
        textLabel.topAnchor.constraint(equalTo: hatImageView.bottomAnchor, constant: 24.0).isActive = true
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[textLabel]-32-|", options: [], metrics: nil, views: views))
    }
    
    func addMotionEffect() {
        
        let motionEffect = UIMotionEffect.hi.twoAxiesShift(40.0)
        avatarImageView.addMotionEffect(motionEffect)
        hatImageView.addMotionEffect(motionEffect)
        textLabel.addMotionEffect(motionEffect)
    }
}
