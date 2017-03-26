//
//  NewFeedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import MobileCoreServices.UTType
import KeyboardMan
import CoreLocation
import RxSwift
import RxCocoa
import RealmSwift
import MapKit
import Kingfisher
import Himarkdown

final class NewFeedViewController: BaseViewController {
   
    // MARK: Public Property
    var viewModel: NewFeedViewModel?
    
    var afterAppeared: (() -> Void)?
    var beforeDisappear: (() -> Void)?
    
    // MARK: UI
    
    @IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var separator: UIView!
    fileprivate lazy var editor: Notepad = {
        let notepad = Notepad(CGRect.zero, themeFile: "k-light")
        notepad.isScrollEnabled = false
        notepad.textContainerInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        notepad.attributedPlaceholder = NSAttributedString(string: self.placeholderOfStory, attributes: [NSForegroundColorAttributeName: UIColor.hi.placeholder, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightLight)])
        return notepad
    }()
    
    @IBOutlet private weak var titleTextField: UITextField! {
        didSet {
            titleTextField.placeholder = Configuration.Defaults.storyTitle
            titleTextField.contentVerticalAlignment = .center
        }
    }
    
    @IBOutlet fileprivate weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 2.0
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.hi.border.cgColor
            imageView.layer.borderWidth = 0.5
            imageView.isHidden = true
        }
    }
    
    @IBOutlet private weak var toolBarBottom: NSLayoutConstraint!
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var visibleButton: UIButton!
    @IBOutlet private weak var markdownButton: UIButton!
    @IBOutlet private weak var storybookButton: UIButton!
    @IBOutlet private weak var detailsButton: UIButton!
    @IBOutlet private weak var keyboardButton: UIButton!
    
    @IBOutlet private weak var postItem: UIBarButtonItem!
    @IBOutlet private weak var cancelItem: UIBarButtonItem!
    @IBOutlet weak var markdownToolbar: MarkdownToolbar!
    
    // MARK: Property
    
    fileprivate lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height / 2 + Constant.normalNavigationBarHeight
        return manager
    }()
    
    fileprivate struct Constant {
        static let scrollViewContentInsetTop: CGFloat = 44.0
        static let footerHeight: CGFloat = 500.0
        static let bottomInset: CGFloat = 20.0
        static let normalNavigationBarHeight: CGFloat = 44.0
    }
    
    private let keyboardMan = KeyboardMan()
    
    private var canLocate = false
    private var location: Variable<LocationInfo?> = Variable(nil)
    
    private let placeholderOfStory = NSLocalizedString("I have beer, do you have story?", comment: "")
    
    private lazy var transitionManager = NonStatusBarTransitionManager()
    
    private var popoverTransitioningDelegate: PopoverTransitioningDelegate?

    private(set) var attachmentImage: Variable<UIImage?> = Variable(nil)
    private var storybook: Variable<Storybook?> = Variable(nil)

    private var isFristTimeAppear = true
    
    // MARK: Methods 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        titleTextField.borderStyle = .none // ⚠️ Fix text offset when inputting
        
        scrollView.contentInset.top = Constant.scrollViewContentInsetTop
        
        setupEditor()
        
        markdownToolbar.selectedAction = { [unowned self] symbol in

            self.editor.insertText(symbol.name)
            
            SafeDispatch.async {
                self.markdownToolbar.isActived = false
            }
        }
        
        let viewModel = self.viewModel ?? NewFeedViewModel(token: UUID().uuidString)
       
        // reference it
        if self.viewModel == nil {
            self.viewModel = viewModel
        }
        
        cancelItem.rx.tap
            .bindTo(viewModel.cancelAction)
            .addDisposableTo(disposeBag)
        
        postItem.rx.tap
            .bindTo(viewModel.postAction)
            .addDisposableTo(disposeBag)
        
        // options
        
        photoButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.picksPhoto()
            })
            .addDisposableTo(disposeBag)
        
        visibleButton.rx.tap
            .map { [unowned self] () -> Bool in
                self.visibleButton.isSelected = !self.visibleButton.isSelected
                return self.visibleButton.isSelected
            }
            .bindTo(viewModel.visible)
            .addDisposableTo(disposeBag)
        
        markdownButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.markdownToolbar.isActived = !self.markdownToolbar.isActived
            })
            .addDisposableTo(disposeBag)
        
        storybookButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.choosesStorybook()
            })
            .addDisposableTo(disposeBag)
        
        detailsButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.showsDetails()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.postButtonEnabled
            .drive(self.postItem.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.dismissViewController
            .drive(onNext: { [weak self] in
                self?.dismiss()
            })
            .addDisposableTo(disposeBag)
      
        // 2 way binding
        (titleTextField.rx.text.orEmpty <-> viewModel.title)
            .addDisposableTo(disposeBag)
        
        (editor.rx.text.orEmpty <-> viewModel.body)
            .addDisposableTo(disposeBag)
       
        (visibleButton.rx.isSelected <-> viewModel.visible)
            .addDisposableTo(disposeBag)
       
        viewModel.attachmentImage.asDriver()
            .filter { [unowned self] image in
                return self.imageView.image == nil
            }
            .map { [weak self] image -> UIImage? in
                self?.fitsImageView(with: image)
                return image
            }
            .drive(imageView.rx.image)
            .addDisposableTo(disposeBag)
        
        viewModel.storybook.asObservable()
            .take(1)
            .debug()
            .bindTo(storybook)
            .addDisposableTo(disposeBag)
        
        location.asObservable()
            .bindTo(viewModel.location)
            .addDisposableTo(disposeBag)
        
        storybook.asObservable()
            .skip(1)
            .debug()
            .bindTo(viewModel.storybook)
            .addDisposableTo(disposeBag)
        
        attachmentImage.asObservable()
            .skip(1)
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
        
        if isFristTimeAppear {
            isFristTimeAppear = false
            afterAppeared?()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func setupEditor() {
        
        contentView.addSubview(editor)
        editor.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["editor": editor]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[editor]|", options: [], metrics: nil, views: views)
        editor.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 24.0).isActive = true
        editor.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 86.0).isActive = true
        NSLayoutConstraint.activate(h)
    }
    
    fileprivate func fitsImageView(with image: UIImage?) {
        
        imageView.isHidden = image == nil
        
        let width = image?.size.width ?? 0.0
        let height = image?.size.height ?? 0.0
        
        let imageViewHeight = width == 0.0 ? 0.0 : contentView.bounds.width * height / width
        contentViewHeightConstraint.constant = imageViewHeight + Constant.footerHeight - view.bounds.height
        imageViewHeightConstraint.constant = imageViewHeight
        
        contentView.layoutIfNeeded()
    }
    
    // MARK: Actions
    
    private func dismiss() {
        editor.resignFirstResponder()
        
        beforeDisappear?()
        
        LocationService.shared.turnOff()
        
        delay(0.2) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func picksPhoto() {
        hi.propose(for: .photos, agreed: { [weak self] in
            let picker = PhotoPickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
            picker.delegate = self
            picker.contentInset.bottom = Constant.bottomInset
            let nav = UINavigationController(rootViewController: picker)
            nav.modalPresentationStyle = .overCurrentContext
            self?.present(nav, animated: true, completion: nil)
        })
    }
    
    private func choosesStorybook() {
        
        guard let userID = HiUserDefaults.userID.value else { return }
        
        let chooser = ChooseStorybookViewController()
        chooser.ownerID = userID
        chooser.selecting = storybook.value?.name
        chooser.selectedAction = { [weak self] storybook in
            self?.storybook.value = storybook
        }
        
        let nav = UINavigationController(rootViewController: chooser)
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = presentationTransitionManager
        
        self.present(nav, animated: true, completion: nil)
    }
    
    private func showsDetails() {
        let viewController = Storyboard.details.viewController(of: DetailsViewController.self)
        let now = Date().timeIntervalSince1970
        viewController.viewModel = DetailsViewModel(body: editor.text, created: viewModel?.createdAt.value ?? now, updated: now, location: location.value)
       
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .crossDissolve
       
        let size: CGSize
        if location.value != nil {
            size = CGSize(width: view.bounds.width - 80.0, height: 300.0)
        } else {
            size = CGSize(width: view.bounds.width - 80.0, height: 250.0)
        }
        
        let shadow = PopoverPresentationShadow(radius: 32.0, color: UIColor.black.withAlphaComponent(0.3))
        let context = PopoverPresentationContext(presentedContentSize: size, cornerRadius: 16.0, chromeAlpha: 0.0, shadow: shadow)
        self.popoverTransitioningDelegate = PopoverTransitioningDelegate(presentationContext: context)
        
        viewController.transitioningDelegate = popoverTransitioningDelegate
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        canLocate = sender.isSelected
        if canLocate && location.value == nil {
            hi.propose(for: .location(.whenInUse), agreed: { [weak self] in
                self?.startLocating()
            })
        }
    }
    
    private func tryToLocate() {
        hi.propose(for: .location(.whenInUse), agreed: { [weak self] in
            self?.startLocating()
        })
    }
    
    private func startLocating() {
        locationButton.isEnabled = false
        
        // Can't location in other thread
        
        let service = LocationService.shared
        service.turnOn()
        
        service.didLocateHandler = { [weak self] result in
            
            DispatchQueue.main.async {
                self?.locationButton.isEnabled = true
                
                switch result {
                    
                case let .success(address, coordinate):
                    self?.location.value = LocationInfo(address: address, coordinate: coordinate)
                    
                    self?.locationButton.isSelected = true
                    self?.canLocate = true
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func handleDismiss(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true) { [weak self] in
            self?.view.center.y += Defaults.statusBarHeight
            completion?()
        }
    }
}

extension NewFeedViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editor.becomeFirstResponder()
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) { 
            textField.invalidateIntrinsicContentSize()
        }
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
        
        updateImageView(with: image, fromPhotoEditingViewController: viewController)
    }
    
    func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        updateImageView(with: image, fromPhotoEditingViewController: viewController)
    }
    
    private func updateImageView(with image: UIImage, fromPhotoEditingViewController viewController: PhotoEditingViewController) {
        
        imageView.image = image
        attachmentImage.value = image
        fitsImageView(with: image)
        
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
