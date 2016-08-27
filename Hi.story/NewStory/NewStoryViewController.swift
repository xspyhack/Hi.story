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
    
    @IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 2.0
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor(hex: Defaults.Color.border).CGColor
            imageView.layer.borderWidth = 0.5
            imageView.hidden = true
        }
    }
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var toolBarBottom: NSLayoutConstraint!

    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var keyboardButton: UIButton!
    @IBOutlet private weak var markdownButton: UIButton!
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var postButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var cancelButtonItem: UIBarButtonItem!
    
    private let keyboardMan = KeyboardMan()
    
    private var canLocate = false
    private var address: String? = nil
    private var coordinate: CLLocationCoordinate2D?
    private var visible: Visible = .Public
    
    private let placeholderOfStory = NSLocalizedString("I have beer, do you have story?", comment: "")
    private var isNeverInputMessage = true
    
    private var isDirty = false {
        willSet {
            postButtonItem.enabled = newValue
            
            if !newValue && isNeverInputMessage {
                textView.text = placeholderOfStory
            }
            
            textView.textColor = newValue ? UIColor(hex: "#353535") : UIColor(hex: "#C7C7C7")
        }
    }

    private lazy var transitionManager = NonStatusBarTransitionManager()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.mediaTypes = [(kUTTypeImage as String)]
        picker.allowsEditing = true
        return picker
    }()
    
    private var pickedImage: UIImage? {
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
    
    var tellStoryDidSuccessAction: ((story: Story) -> Void)?
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        view.endEditing(true)
    }
    
    // MARK: Actions
    
    private func dismiss() {
        textView.resignFirstResponder()
        
        delay(0.2) { [weak self] in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func tryToPostNewStory() {
        
        textView.resignFirstResponder()
        
        guard let storyContent = textView.text else {
            return
        }
        
        ActivityIndicator.sharedInstance.show()
        
        let title = titleTextField.text ?? NSDate().xh_yearMonthDay
        
        let creationDate = NSDate().timeIntervalSince1970
        let story = Story()
        story.body = storyContent
        story.title = title
        story.createdUnixTime = creationDate
        story.updatedUnixTime = creationDate
        story.visible = visible.rawValue
        
        if let image = imageView.image {
            let URL = NSURL.hi_imageURL(withPath: NSDate().xh_timestamp)
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
        
        DispatchQueue.async(on: .Main) {
            ActivityIndicator.sharedInstance.hide()
        }
        
        DispatchQueue.async(on: .Main) { [weak self] in
            self?.tellStoryDidSuccessAction?(story: story)
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func visibleButtonTapped(sender: UIButton) {
        sender.selected = !sender.selected
        if sender.selected {
            visible = .Public
        } else {
            visible = .Private
        }
    }

    @IBAction func locationButtonTapped(sender: UIButton) {
        sender.selected = !sender.selected
        
        canLocate = sender.selected
        if canLocate && coordinate == nil {
            let permission: Permission = .LocationWhenInUse
            permission.request { [weak self](status) in
                switch permission.status {
                case .Authorized:
                    self?.startLocating()
                case .Denied:
                    print("denied")
                case .Disabled:
                    print("disabled")
                case .NotDetermined:
                    self?.startLocating()
                }
            }
        }
    }
    
    @IBAction func pickButtonTapped(sender: UIButton) {
        imagePicker.transitioningDelegate = transitionManager
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func tryToLocate() {
        let permission: Permission = .LocationWhenInUse
        if permission.status == .Authorized {
            startLocating()
        }
    }
    
    private func startLocating() {
        locationButton.enabled = false
        
        locateInBackground()
    }
    
    private func locateInBackground() {
        
        DispatchQueue.async(on: .Default) { 
            
            let service = LocationService.shareService
            service.turnOn()
            
            service.didLocateHandler = { [weak self] result in
                
                DispatchQueue.async(on: .Main, forWork: { 
                    
                    self?.locationButton.enabled = true
                    
                    switch result {
                        
                    case let .Success(address, coordinate):
                        self?.coordinate = coordinate
                        self?.address = address
                        self?.locationButton.selected = true
                        self?.canLocate = true
                        
                    case .Failure(let error):
                        print(error)
                    }
                })
            }

        }
    }
    
    private func handleDismiss() {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.view.center.y += Defaults.statusBarHeight
        }
    }
}

extension NewStoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
}

extension NewStoryViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if !isDirty {
            textView.text = ""
        }
        
        isNeverInputMessage = false
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        isDirty = NSString(string: textView.text).length > 0
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
}

extension NewStoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        handleDismiss()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            switch mediaType {
            case kUTTypeImage as String as String:
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    imageView.hidden = false
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
