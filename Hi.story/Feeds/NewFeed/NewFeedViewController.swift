//
//  NewFeedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import MobileCoreServices.UTType
import KeyboardMan
//import Permission
import Hikit
import RxSwift
import RxCocoa
import RealmSwift
import MapKit
import Kingfisher

final class NewFeedViewController: BaseViewController {
    
    var viewModel: NewFeedViewModel?
    
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
    @IBOutlet fileprivate weak var textView: NextTextView! {
        didSet {
            textView.attributedPlaceholder = NSAttributedString(string: placeholderOfStory, attributes: [NSForegroundColorAttributeName: UIColor.hi.placeholder])
            textView.textColor = UIColor.hi.text
            textView.tintColor = UIColor.hi.text
        }
    }
    @IBOutlet fileprivate weak var toolBarBottom: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var visibleButton: UIButton!
    @IBOutlet private weak var keyboardButton: UIButton!
    @IBOutlet private weak var markdownButton: UIButton!
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet private weak var locationButton: UIButton!
    
    @IBOutlet private weak var postItem: UIBarButtonItem!
    @IBOutlet private weak var cancelItem: UIBarButtonItem!
    
    fileprivate struct Constant {
        static let scrollViewContentInsetTop = 44.0
    }
    
    private let keyboardMan = KeyboardMan()
    
    private var canLocate = false
    private var address: String? = nil
    private var coordinate: CLLocationCoordinate2D?
    
    fileprivate let placeholderOfStory = NSLocalizedString("I have beer, do you have story?", comment: "")
    
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
            
            self.attachmentImage.value = newValue
            
            let width = image.size.width
            let height = image.size.height
            
            let imageViewHeight = contentView.bounds.width * height / width
            contentViewHeightConstraint.constant = imageViewHeight + 500.0 - view.bounds.height
            imageViewHeightConstraint.constant = imageViewHeight
            
            contentView.layoutIfNeeded()
        }
    }
    
    private var attachmentImage: Variable<UIImage?> = Variable(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        scrollView.contentInset.top = 44.0
        
        textView.textContainerInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        
        let viewModel = self.viewModel ?? NewFeedViewModel()
        
        visibleButton.rx.tap
            .map { [unowned self] () -> Bool in
                self.visibleButton.isSelected = !self.visibleButton.isSelected
                return self.visibleButton.isSelected
            }
            .bindTo(viewModel.visible)
            .addDisposableTo(disposeBag)
        
        cancelItem.rx.tap
            .bindTo(viewModel.cancelAction)
            .addDisposableTo(disposeBag)
        
        postItem.rx.tap
            .bindTo(viewModel.postAction)
            .addDisposableTo(disposeBag)
        
        visibleButton.rx.tap
            .bindTo(viewModel.visibleAction)
            .addDisposableTo(disposeBag)
        
        viewModel.postButtonEnabled
            .drive(self.postItem.rx.enabled)
            .addDisposableTo(disposeBag)
        
        viewModel.dismissViewController
            .drive(onNext: { [weak self] in
                self?.dismiss()
            })
            .addDisposableTo(disposeBag)
        
        titleTextField.rx.text
            .bindTo(viewModel.title)
            .addDisposableTo(disposeBag)
        
        textView.rx.text
            .bindTo(viewModel.body)
            .addDisposableTo(disposeBag)
        
        attachmentImage.asObservable()
            .bindTo(viewModel.attachmentImage)
            .addDisposableTo(disposeBag)
    
        keyboardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .addDisposableTo(disposeBag)
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            if let sSelf = self {
                sSelf.toolBarBottom.constant += keyboardHeightIncrement
                sSelf.view.layoutIfNeeded()
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            if let sSelf = self {
                sSelf.toolBarBottom.constant -= keyboardHeight
                sSelf.view.layoutIfNeeded()
            }
        }
        
        tryToLocate()
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
    
    private func dismiss() {
        textView.resignFirstResponder()
        
        delay(0.2) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        canLocate = sender.isSelected
        if canLocate && coordinate == nil {
            /*
            let permission: Permission = .LocationWhenInUse
            permission.request { [weak self] (status) in
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
            }*/
        }
    }
    
    @IBAction func pickButtonTapped(_ sender: UIButton) {
        imagePicker.transitioningDelegate = transitionManager
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func tryToLocate() {
        /*
        let permission: Permission = .LocationWhenInUse
        if permission.status == .authorized {
            startLocating()
        }*/
    }
    
    fileprivate func startLocating() {
        locationButton.isEnabled = false
        
        locateInBackground()
    }
    
    fileprivate func locateInBackground() {
        
        DispatchQueue.global(qos: .default).async {
            let service = LocationService.shared
            service.turnOn()
            
            service.didLocateHandler = { [weak self] result in
                
                DispatchQueue.main.sync {
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
                }
            }
        }
    }
    
    fileprivate func handleDismiss() {
        self.dismiss(animated: true) { [weak self] in
            self?.view.center.y += Defaults.statusBarHeight
        }
    }
}

extension NewFeedViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
}

extension NewFeedViewController: UITextViewDelegate {
}

extension NewFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
