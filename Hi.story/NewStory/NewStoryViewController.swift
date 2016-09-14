//
//  NewStoryViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/29/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import MobileCoreServices.UTType
import KeyboardMan
import Permission
import Hikit
import RxSwift
import RxCocoa
import RealmSwift
import MapKit
import Kingfisher

final class NewStoryViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    
    @IBOutlet fileprivate weak var titleTextField: UITextField!
    @IBOutlet fileprivate weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 2.0
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor(hex: Defaults.Color.border).cgColor
            imageView.layer.borderWidth = 0.5
            imageView.isHidden = true
        }
    }
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var toolBarBottom: NSLayoutConstraint!

    @IBOutlet fileprivate weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var keyboardButton: UIButton!
    @IBOutlet fileprivate weak var markdownButton: UIButton!
    @IBOutlet fileprivate weak var photoButton: UIButton!
    @IBOutlet fileprivate weak var locationButton: UIButton!
    @IBOutlet fileprivate weak var postButtonItem: UIBarButtonItem!
    
    @IBOutlet fileprivate weak var cancelButtonItem: UIBarButtonItem!
    
    fileprivate let keyboardMan = KeyboardMan
    
    fileprivate var canLocate = false
    fileprivate var address: String? = nil
    fileprivate var coordinate: CLLocationCoordinate2D?
    fileprivate var visible: Visible = .public
    
    fileprivate let placeholderOfStory = NSLocalizedString("I have beer, do you have story?", comment: "")
    fileprivate var isNeverInputMessage = true
    
    fileprivate var isDirty = false {
        willSet {
            postButtonItem.isEnabled = newValue
            
            if !newValue && isNeverInputMessage {
                textView.text = placeholderOfStory
            }
            
            textView.textColor = newValue ? UIColor(hex: "#353535") : UIColor(hex: "#C7C7C7")
        }
    }

    fileprivate lazy var transitionManager = NonStatusBarTransitionManager()
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.mediaTypes = [(kUTTypeImage as String)]
        picker.allowsEditing = true
        return picker
    }()
    
    fileprivate var pickedImage: UIImage? {
        willSet {
            guard let image = newValue else { return }
            
            let width = image.size.width
            let height = image.size.height
            
            let imageViewHeight = contentView.bounds.width * height / width
            contentViewHeightConstraint.constant = imageViewHeight + 500.0
            imageViewHeightConstraint.constant = imageViewHeight
            
            contentView.layoutIfNeeded()
        }
    }
    
    var tellStoryDidSuccessAction: ((_ story: Story) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        scrollView.contentInset.top = 44.0
        
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        isDirty = false
        
        // MARK: Config
        
        postButtonItem.rx_tap
            .subscribeNext { [weak self] in
                self?.tryToPostNewStory()
            }
            .addDisposableTo(disposeBag)
        
        cancelButtonItem.rx_tap
            .subscribeNext { [weak self] in
                self?.handleDismiss()
            }.addDisposableTo(disposeBag)
        
        keyboardButton.rx_tap
            .subscribeNext { [weak self] in
                self?.view.endEditing(true)
            }
            .addDisposableTo(disposeBag)
        
        tryToLocate()
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            if let strongSelf = self {
                strongSelf.toolBarBottom.constant += keyboardHeightIncrement
                strongSelf.view.layoutIfNeeded()
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            if let strongSelf = self {
                strongSelf.toolBarBottom.constant -= keyboardHeight
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    // MARK: Actions
    
    fileprivate func dismiss() {
        textView.resignFirstResponder()
        
        delay(0.2) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func tryToPostNewStory() {
        
        textView.resignFirstResponder()
        
        guard let storyContent = textView.text else {
            return
        }
        
        ActivityIndicator.sharedInstance.show()
        
        let title = titleTextField.text ?? Date().hi.yearMonthDay
        
        let creationDate = Date().timeIntervalSince1970
        let story = Story()
        story.body = storyContent
        story.title = title
        story.createdUnixTime = creationDate
        story.updatedUnixTime = creationDate
        story.visible = visible.rawValue
        
        if let image = imageView.image {
            let URL = Foundation.URL.hi.imageURL(withPath: Date().hi.timestamp)
            ImageStorage.sharedStorage.storeImage(image, forKey: URL.absoluteString)
            let attachment = Attachment()
            attachment.URLString = URL.absoluteString
            story.attachment = attachment
        }

        if canLocate, let coordinateInfo = coordinate {

            let location = Location()
            location.name = address ?? ""
            
            let coordinate = Coordinate()
            coordinate.safeConfigure(withLatitude: coordinateInfo.latitude, longitude: coordinateInfo.longitude)
            location.coordinate = coordinate
            
            story.location = location
        }
        
        guard let realm = try? Realm() else { return }
        
        StoryService.sharedService.synchronize(story, toRealm: realm)
        
        DispatchQueue.async(on: .main) {
            ActivityIndicator.sharedInstance.hide()
        }
        
        DispatchQueue.async(on: .main) { [weak self] in
            self?.tellStoryDidSuccessAction?(story: story)
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func visibleButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            visible = .public
        } else {
            visible = .private
        }
    }

    @IBAction func locationButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        canLocate = sender.isSelected
        if canLocate && coordinate == nil {
            let permission: Permission = .LocationWhenInUse
            permission.request { [weak self](status) in
                switch permission.status {
                case .authorized:
                    self?.startLocating()
                case .denied:
                    print("denied")
                case .disabled:
                    print("disabled")
                case .notDetermined:
                    self?.startLocating()
                }
            }
        }
    }
    
    @IBAction func pickButtonTapped(_ sender: UIButton) {
        imagePicker.transitioningDelegate = transitionManager
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func tryToLocate() {
        let permission: Permission = .LocationWhenInUse
        if permission.status == .authorized {
            startLocating()
        }
    }
    
    fileprivate func startLocating() {
        locationButton.isEnabled = false
        
        locateInBackground()
    }
    
    fileprivate func locateInBackground() {
        
        DispatchQueue.async(on: .default) { 
            
            let service = LocationService.shareService
            service.turnOn()
            
            service.didLocateHandler = { [weak self] result in
                
                DispatchQueue.async(on: .main, forWork: { 
                    
                    self?.locationButton.isEnabled = true
                    
                    switch result {
                        
                    case let .success(address, coordinate):
                        self?.coordinate = coordinate
                        self?.address = address
                        self?.locationButton.isSelected = true
                        self?.canLocate = true
                        
                    case .failure(let error):
                        print(error)
                    }
                })
            }

        }
    }
    
    fileprivate func handleDismiss() {
        self.dismiss(animated: true) { [weak self] in
            self?.view.center.y += Defaults.statusBarHeight
        }
    }
}

extension NewStoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
}

extension NewStoryViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if !isDirty {
            textView.text = ""
        }
        
        isNeverInputMessage = false
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        isDirty = NSString(string: textView.text).length > 0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
}

extension NewStoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        handleDismiss()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            switch mediaType {
            case kUTTypeImage as String as String:
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    imageView.isHidden = false
                    imageView.image = image
                    pickedImage = image
                }
            default:
                break
            }
        }
        
        handleDismiss()
    }
}
