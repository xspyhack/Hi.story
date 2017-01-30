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
import KeyboardMan
import RealmSwift

final class EditProfileViewController: BaseViewController {

    @IBOutlet weak var promptLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var promptLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.hi.register(reusableCell: InputableCell.self)
            tableView.hi.register(reusableCell: InfoInputableCell.self)
            tableView.backgroundColor = UIColor.hi.background
        }
    }
    
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var avatarImageView: UIImageView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer()
            tapRecognizer.rx.event
                .subscribe(onNext: { [weak self] _ in
                    self?.pickPhoto()
                })
                .addDisposableTo(disposeBag)
            avatarImageView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    private struct Listener {
        static let nickname = "EditProfileoCell.nickname"
        static let bio = "EditProfileCell.bio"
    }
    
    struct Constant {
        static let avatarSize = CGSize(width: 100.0, height: 100.0)
    }
    
    fileprivate var avatarIsDirty = false
    fileprivate var profileIsDirty = Variable(false)
    fileprivate var usernameAvailable = Variable(true)
    
    fileprivate lazy var doneItem: UIBarButtonItem = {
        let doneItem = UIBarButtonItem()
        doneItem.title = "Done"
        doneItem.style = .done
        doneItem.isEnabled = false
        return doneItem
    }()
    
    private let keyboardMan = KeyboardMan()
    
    fileprivate var username: String?
    fileprivate var nickname: String?
    fileprivate var bio: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Profile"
        navigationItem.rightBarButtonItem = doneItem
        
        let avatar = HiUserDefaults.avatar.value
        avatarImageView.setImage(with: avatar.flatMap { URL(string: $0) }, placeholder: UIImage.hi.roundedAvatar(radius: Constant.avatarSize.width), transformer: .rounded(Constant.avatarSize))
       
        doneItem.rx.tap
            .subscribe(onNext: { [weak self] in
                // save avatar
                self?.view.endEditing(true)
                self?.activityIndicator.startAnimating()
                let url = self?.savedPhoto()
                HiUserDefaults.avatar.value = url?.absoluteString
                HiUserDefaults.bio.value = self?.bio
                HiUserDefaults.nickname.value = self?.nickname
                
                if let username = self?.username {
                    guard let realm = try? Realm() else { return }
                    
                    let me = Service.god(of: realm)
                    try? realm.write {
                        me?.username = username.lowercased()
                    }
                    
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
                
                self?.activityIndicator.stopAnimating()
                self?.profileIsDirty.value = false
                self?.avatarIsDirty = false
            })
            .addDisposableTo(disposeBag)
        
        Observable.combineLatest(profileIsDirty.asObservable(), usernameAvailable.asObservable()) { dirty, available in
                dirty || available
            }
            .bindTo(doneItem.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            self?.promptLabelBottomConstraint.constant = keyboardHeight
            self?.view.layoutIfNeeded()
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] _ in
            self?.promptLabelBottomConstraint.constant = 0.0
            self?.view.layoutIfNeeded()
        }
    }

    deinit {
        HiUserDefaults.nickname.removeListener(with: Listener.nickname)
        
        tableView?.delegate = nil
    }
    
    private func pickPhoto() {
       
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let choosePhotoAction = UIAlertAction(title: "Choose", style: .default) { [weak self] _ in
           
            let pickAction = {
                let picker = PhotoPickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
                picker.delegate = self
                let nav = UINavigationController(rootViewController: picker)
                self?.present(nav, animated: true, completion: nil)
            }
            
            self?.hi.propose(for: .photos, agreed: pickAction)
        }
        
        alertController.addAction(choosePhotoAction)
        
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default) { [weak self] _ in
            
            let takeAction = {
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    return
                }
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                
                self?.present(imagePicker, animated: true, completion: nil)
            }
            
            self?.hi.propose(for: .camera, agreed: takeAction)
        }
        alertController.addAction(takePhotoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        // touch to create (if need) for faster appear
        _ = delay(0.2) { [weak self] in
            self?.imagePicker.hidesBarsOnTap = false
        }
    }
    
    private func savedPhoto() -> URL? {
        guard avatarIsDirty else { return nil }
        
        let url = URL.hi.imageURL(withPath: Date().hi.timestamp)
        if let image = avatarImageView.image {
            CacheService.shared.store(image, forKey: url.absoluteString)
            return url
        } else {
            CacheService.shared.removeIfExisting(forKey: url.absoluteString)
            return nil
        }
    }
}

extension EditProfileViewController: UITableViewDataSource {
    
    enum Row: Int {
        case username
        case nickname
        case bio
        
        var annotation: String {
            switch self {
            case .username: return "Username"
            case .nickname: return "Nickname"
            case .bio: return "Bio"
            }
        }
        
        static var count: Int {
            return Row.bio.rawValue + 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = Row(rawValue: indexPath.row) else { fatalError() }
        
        switch row {
        case .username:
            let cell: InputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = row.annotation
            cell.textField.textAlignment = .right
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            cell.didBeginInputingAction = { [weak self] in
                self?.promptLabel.isHidden = false
            }
            
            let username = Service.god?.username ?? ""
            if username.isEmpty {
                cell.changedAction = { [unowned self] newValue in
                    self.username = newValue
                    let invalided = ValidationService.validate(username: newValue)
                        .observeOn(MainScheduler.asyncInstance)
                        .shareReplay(1)
                    
                    invalided
                        .bindTo(self.promptLabel.rx.validationResult)
                        .addDisposableTo(cell.rx.prepareForReuseBag)
                    
                    invalided
                        .map { $0.isValid }
                        .bindTo(self.usernameAvailable)
                        .addDisposableTo(cell.rx.prepareForReuseBag)
               
                }
                cell.didEndInputingAction = { [weak self] in
                    self?.promptLabel.isHidden = true
                }
            } else {
                cell.textField.text = username
                cell.textField.isEnabled = false
            }
            return cell
        case .nickname:
            let cell: InputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = row.annotation
            cell.textField.textAlignment = .right
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            HiUserDefaults.nickname.bindAndFireListener(with: "EditProfile.nickname") { [weak self] nickname in
                cell.textField.text = nickname
                self?.nickname = nickname
            }
            cell.changedAction = { [weak self] newValue in
                self?.nickname = newValue
                self?.profileIsDirty.value = true
            }
            return cell
        case .bio:
            let cell: InfoInputableCell = tableView.hi.dequeueReusableCell(for: indexPath)
            cell.titleLabel.text = row.annotation
            cell.selectionStyle = .none
            HiUserDefaults.bio.bindAndFireListener(with: "EditProfile.bio") { [weak self] bio in
                cell.textView.text = bio
                self?.bio = bio
            }
            
            cell.didEndEditing = { [weak self] bio in
                self?.bio = bio
                self?.profileIsDirty.value = true
            }
            return cell
        }
    }
}

extension EditProfileViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Row(rawValue: indexPath.row) else {
            fatalError()
        }
        
        switch row {
        case .bio: return InfoInputableCell.minixumHeight + 1.0
        default: return 60.0
        }
    }
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
        profileIsDirty.value = true
        avatarImageView.image = image
        
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension Reactive where Base: UILabel {
    var validationResult: UIBindingObserver<Base, ValidationResult> {
        return UIBindingObserver(UIElement: base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return UIColor.blue
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return UIColor.red
        }
    }
}
