//
//  PhotoCropperViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 9/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

final class PhotoCropperViewController: UIViewController {

    var photoForCrop: UIImage?
    var croppedAction: ((UIImage) -> Void)?

    private lazy var previewView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var headerMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private lazy var footerMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private lazy var croppedView: UIView = {
        let view = UIView()
        return view()
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Confirm", for: .normal)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Cancel", for: .normal)
        return button
    }

    private lazy var zoomableImageView: ZoomableImageView = {
        let imageView = ZoomableImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.clipsToBounds = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        croppedView.backgroundColor = UIColor.clear
        setup()
        
        if photoForCrop == nil {
            show(message: "Can't get the photo.") {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        zoomableImageView.imageSize = photo.size
        zoomableImageView.image = photo
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    private func setup() {
        
        view.addSubview(croppedView)
        croppedView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerMaskView)
        headerMaskView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(footerMaskView)
        footerMaskView.translatesAutoresizingMaskIntoConstraints = false

        croppedView.addSubview(zoomableImageView)
        zoomableImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let views: [String: Any] = [
            "croppedView": croppedView,
            "previewView": previewView,
            "headerMaskView": headerMaskView,
            "footerMaskView": footerMaskView,
            "zoomableImageView": zoomableImageView,
            "confirmButton": confirmButton,
            "cancelButton": cancelButton,
        ]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[croppedView]|", options: [], metrics: nil, views: views)
        let croppedViewRatioConstraint = NSLayoutConstraint(item: croppedView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0.0)
        let croppedViewCenterYContraint = NSLayoutConstraint(item: croppedView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[headerMaskView][croppedView][footerMaskView]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)

        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
        
        NSLayoutConstraint.activate([croppedViewRatioConstraint, croppedViewCenterYContraint])
        
        let previewViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[previewView]|", options: [], metrics: nil, views: views)
        let previewViewRatioConstraint = NSLayoutConstraint(item: previewView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0.0)
        let previewViewCenterYContraint = NSLayoutConstraint(item: previewView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(previewViewHConstraints)
        NSLayoutConstraint.activate([previewViewRatioConstraint, previewViewCenterYContraint])
        
        let zoomableImageViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[zoomableImageView]|", options: [], metrics: nil, views: views)
        let zoomableImageViewVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[zoomableImageView]|", options: [], metrics: nil, views: views)

        NSLayoutConstraint.activate(zoomableImageViewHConstraints)
        NSLayoutConstraint.activate(zoomableImageViewVConstraints)
        
        let buttonHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cancelButton]-(>100)-[confirmButton]-20-|", options: [.alignAllBottom], metrics: nil, views: views)
        
        let buttonVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelButton]-20-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(buttonHConstraints)
        NSLayoutConstraint.activate(buttonVConstraints)
    }

    @objc private func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func confirmAction(_ sender: UIButton) {

        previewView.backgroundColor = UIColor.clear

        if let image = croppedView.bub.capture() {
            croppedAction?(image)
            dismiss(animated: true, completion: nil)
        } else {
            show(message: "Crop fail.") {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func show(message: String, completion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
            completion?()
        }
        
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }

}
