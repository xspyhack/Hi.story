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
import CoreLocation
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
            textView.attributedPlaceholder = NSAttributedString(string: placeholderOfStory, attributes: [NSForegroundColorAttributeName: UIColor.hi.placeholder, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightLight)])
            textView.textColor = UIColor.hi.text
            textView.tintColor = UIColor.hi.text
            textView.font = UIFont.systemFont(ofSize: 14.0)
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
        static let footerHeight: CGFloat = 500.0
        static let bottomInset: CGFloat = 20.0
    }
    
    private let keyboardMan = KeyboardMan()
    
    private var canLocate = false
    private var address: String? = nil
    private var coordinate: CLLocationCoordinate2D?
    
    fileprivate var croppedFrame: CGRect = .zero
    fileprivate var angle: Int = 0
    
    fileprivate let placeholderOfStory = NSLocalizedString("I have beer, do you have story?", comment: "")
    
    fileprivate lazy var transitionManager = NonStatusBarTransitionManager()
    
//    fileprivate lazy var photoPicker: PhotoPickerViewController = {
//        let picker = PhotoPickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
//        return picker
//    }()
//    
    fileprivate var pickedImage: UIImage? {
        willSet {
            guard let image = newValue else { return }
            
            self.attachmentImage.value = newValue
            
            let width = image.size.width
            let height = image.size.height
            
            let imageViewHeight = contentView.bounds.width * height / width
            contentViewHeightConstraint.constant = imageViewHeight + Constant.footerHeight - view.bounds.height
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
        
        photoButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let picker = PhotoPickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
                picker.delegate = self
                picker.contentInset.bottom = Constant.bottomInset
                let nav = UINavigationController(rootViewController: picker)
                nav.modalPresentationStyle = .overCurrentContext
                self.present(nav, animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
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
        
        titleTextField.rx.text.orEmpty
            .bindTo(viewModel.title)
            .addDisposableTo(disposeBag)
        
        textView.rx.text.orEmpty
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        
    }
    
    fileprivate func tryToLocate() {
        /*
        let permission: Permission = .LocationWhenInUse
        if permission.status == .authorized {
            startLocating()
        }*/
    }
    
    private func startLocating() {
        locationButton.isEnabled = false
        
        locateInBackground()
    }
    
    private func locateInBackground() {
        
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
    
    fileprivate func handleDismiss(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true) { [weak self] in
            self?.view.center.y += Defaults.statusBarHeight
            completion?()
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

extension NewFeedViewController: PhotoPickerViewControllerDelegate {
    
    func photoPickerControllerDidCancel(_ picker: PhotoPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func photoPickerController(_ picker: PhotoPickerViewController, didFinishPickingPhoto photo: UIImage) {
        
        let viewController = PhotoEditingViewController(image: photo, croppingStyle: .default)
        
        viewController.delegate = self
        viewController.contentInset.bottom = Constant.bottomInset
        viewController.modalPresentationStyle = .overCurrentContext
        
        dismiss(animated: true) {
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension NewFeedViewController: PhotoEditingViewControllerDelegate {
    
    func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.croppedFrame = cropRect
        self.angle = angle
        
        updateImageView(with: image, fromPhotoEditingViewController: viewController)
    }
    
    func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.croppedFrame = cropRect
        self.angle = angle
        
        updateImageView(with: image, fromPhotoEditingViewController: viewController)
    }
    
    private func updateImageView(with image: UIImage, fromPhotoEditingViewController viewController: PhotoEditingViewController) {
        
        imageView.image = image
        pickedImage = image
        
        if viewController.croppingStyle != .circular {
            
            imageView.isHidden = false

            viewController.presentingViewController?.dismiss(animated: true) {
                print("did comlete")
            }
            
        } else {
            imageView.isHidden = false
            
            viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
