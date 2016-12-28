//
//  EditProfileViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 19/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import RxSwift
import RxCocoa

final class EditProfileViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var avatarImageView: UIImageView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer()
            tapRecognizer.rx.event
                .subscribe(onNext: { _ in
                    self.showActionSheel()
                })
                .addDisposableTo(disposeBag)
            avatarImageView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    fileprivate lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditProfileViewController.save(_:)))
        return button
    }()
    
    fileprivate struct Listener {
        static let nickname = "EditProfileoCell.nickname"
        static let bio = "EditProfileCell.bio"
    }
    
    fileprivate var avatarIsDirty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = doneButton
       
        doneButton.rx.tap
            .subscribe(onNext: {
                // save avatar
            })
            .addDisposableTo(disposeBag)
    }

    deinit {
        HiUserDefaults.nickname.removeListener(with: Listener.nickname)
        
        tableView?.delegate = nil
    }
    
    private func showActionSheel() {
       
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let choosePhotoAction: UIAlertAction = UIAlertAction(title: "Choose", style: .default) { [weak self] _ in
           
            let picker = PhotoPickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
            picker.delegate = self
            let nav = UINavigationController(rootViewController: picker)
            self?.present(nav, animated: true, completion: nil)
        }
        
        alertController.addAction(choosePhotoAction)
        
        let takePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default) { [weak self] _ in
            
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            self?.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(takePhotoAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        // touch to create (if need) for faster appear
        _ = delay(0.2) { [weak self] in
            self?.imagePicker.hidesBarsOnTap = false
        }
    }
    
    @objc private func save(_ sender: UIBarButtonItem) {
        
        view.endEditing(true)
    }
}

extension EditProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension EditProfileViewController: UITableViewDelegate {
    
}

// MARK: UIImagePicker

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let viewController = PhotoEditingViewController(image: image, croppingStyle: .circular)
        viewController.delegate = self
       
        dismiss(animated: true) { 
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - PhotoPickerViewControllerDelegate

extension EditProfileViewController: PhotoPickerViewControllerDelegate {
    
    func photoPickerControllerDidCancel(_ picker: PhotoPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func photoPickerController(_ picker: PhotoPickerViewController, didFinishPickingPhoto photo: UIImage) {
        
        let viewController = PhotoEditingViewController(image: photo, croppingStyle: .circular)
        viewController.delegate = self
        
        dismiss(animated: true) {
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - PhotoEditingViewControllerDelegate

extension EditProfileViewController: PhotoEditingViewControllerDelegate {
    
    func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
      
        avatarIsDirty = true
        avatarImageView.image = image
        
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
