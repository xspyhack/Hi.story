//
//  NewFeedViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import Hiprelude
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
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet private weak var separator: UIView!
    
    private lazy var editor: Notepad = {
        let notepad = Notepad(CGRect.zero, themeFile: "k-light")
        notepad.isScrollEnabled = false
        notepad.textContainerInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        notepad.attributedPlaceholder = NSAttributedString(string: self.placeholderOfStory, attributes: [NSAttributedStringKey.foregroundColor: UIColor.hi.placeholder, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.light)])
        return notepad
    }()
    
    @IBOutlet private weak var titleTextField: UITextField! {
        didSet {
            titleTextField.placeholder = Configuration.Defaults.storyTitle
            titleTextField.contentVerticalAlignment = .center
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
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
    private lazy var markdownToolbar: MarkdownToolbar = {
        return MarkdownToolbar(operations: MarkdownCoordinator.defaultOperations)
    }()
    
    @IBOutlet weak var buttonItemWidthConstraint: NSLayoutConstraint!
    
    private lazy var toolbarAccessoryView: InputAccessoryView = {
        return InputAccessoryView(for: toolbar, contentInset: UIEdgeInsets(top: Constant.markdownToolbarHeight, left: 0, bottom: 0, right: 0))
    }()
    
    // MARK: Property
    
    private lazy var markdownCoordinator = MarkdownCoordinator()
    
    private lazy var presentationTransitionManager: PresentationTransitionManager = {
        let manager = PresentationTransitionManager()
        manager.presentedViewHeight = self.view.bounds.height / 2 + Constant.normalNavigationBarHeight
        return manager
    }()
    
    private struct Constant {
        static let scrollViewContentInsetTop: CGFloat = 44.0
        static let footerHeight: CGFloat = 500.0
        static let bottomInset: CGFloat = 20.0
        static let normalNavigationBarHeight: CGFloat = 44.0
        static let markdownToolbarHeight: CGFloat = 45.0
    }
    
    private let keyboardMan = KeyboardMan()
    
    private var canLocate: Bool {
        return locationButton.isSelected
    }
    private var location: Variable<LocationInfo?> = Variable(nil)
    
    private let placeholderOfStory = NSLocalizedString("I have beer, do you have story?", comment: "")
    
    private lazy var transitionManager = NonStatusBarTransitionManager()
    
    private var popoverTransitioningDelegate: PopoverTransitioningDelegate?

    private(set) var attachmentImage: Variable<UIImage?> = Variable(nil)
    private var storybook: Variable<Storybook?> = Variable(nil)
    
    // MARK: Methods 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubview()
        
        setupEditor()
        
        setupMarkdownToolbar()
        
        let viewModel = self.viewModel ?? NewFeedViewModel(token: UUID().uuidString)
       
        // reference it
        if self.viewModel == nil {
            self.viewModel = viewModel
        }
        
        cancelItem.rx.tap
            .bind(to: viewModel.cancelAction)
            .disposed(by: disposeBag)
        
        postItem.rx.tap
            .bind(to: viewModel.postAction)
            .disposed(by: disposeBag)
        
        // options
        
        photoButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.picksPhoto()
            })
            .disposed(by: disposeBag)
        
        locationButton.rx.tap
            .do(onNext: { [unowned self] in
                self.locationButton.isSelected = !self.locationButton.isSelected
            })
            .map { [unowned self] in
                return self.canLocate
            }
            .flatMap(tryLocating)
            .do(onNext: { [weak self] _ in
                self?.locationButton.isEnabled = false
            })
            .flatMap(onLocating)
            .do(onNext: { [weak self] _ in
                self?.locationButton.isEnabled = true
            })
            .map { result -> LocationInfo? in
                return result.value.flatMap { $0 }
            }
            .bind(to: location)
            .disposed(by: disposeBag)
        
        location.asDriver()
            .map { $0 != nil }
            .debug()
            .drive(onNext: {
                self.locationButton.isSelected = $0
            })
            .disposed(by: disposeBag)
        
        visibleButton.rx.tap
            .do(onNext: { [unowned self] in
                self.visibleButton.isSelected = !self.visibleButton.isSelected
            })
            .map { [unowned self] () -> Bool in
                return self.visibleButton.isSelected
            }
            .bind(to: viewModel.visible)
            .disposed(by: disposeBag)
        
        markdownButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.markdownToolbar.isActived = !self.markdownToolbar.isActived
            })
            .disposed(by: disposeBag)
        
        storybookButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.choosesStorybook()
            })
            .disposed(by: disposeBag)
        
        detailsButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.showsDetails()
            })
            .disposed(by: disposeBag)
        
        viewModel.postButtonEnabled
            .drive(self.postItem.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.dismissViewController
            .drive(onNext: { [weak self] in
                self?.dismiss()
            })
            .disposed(by: disposeBag)
      
        // 2 way binding
        (titleTextField.rx.text.orEmpty <-> viewModel.title)
            .disposed(by: disposeBag)
        
        (editor.rx.text.orEmpty <-> viewModel.body)
            .disposed(by: disposeBag)
       
        (visibleButton.rx.selected <-> viewModel.visible)
            .disposed(by: disposeBag)
       
        viewModel.attachmentImage.asDriver()
            .filter { [unowned self] image in
                return self.imageView.image == nil
            }
            .map { [weak self] image -> UIImage? in
                self?.fitsImageView(with: image)
                return image
            }
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.storybook.asObservable()
            .take(1)
            .debug()
            .bind(to: storybook)
            .disposed(by: disposeBag)
        
        location.asObservable()
            .bind(to: viewModel.location)
            .disposed(by: disposeBag)
        
        storybook.asObservable()
            .skip(1)
            .debug()
            .bind(to: viewModel.storybook)
            .disposed(by: disposeBag)
        
        attachmentImage.asObservable()
            .skip(1)
            .bind(to: viewModel.attachmentImage)
            .disposed(by: disposeBag)
    
        keyboardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        tryLocating(true)
            .take(1)
            .flatMap(onLocating)
            .map { result -> LocationInfo? in
                return result.value.flatMap { $0 }
            }
            .bind(to: location)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)

        afterAppeared?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        markdownToolbar.isActived = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var inputAccessoryView: UIView? {
        return toolbarAccessoryView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    
    // MARK: - UI setup
    
    private func setupSubview() {
        
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        
        titleTextField.borderStyle = .none // ⚠️ Fix text offset when inputting
        
        scrollView.contentInset.top = Constant.scrollViewContentInsetTop
        scrollView.keyboardDismissMode = .interactive
        
        // 简单的调整，暂时不需要 Ruler
        if let keyWindow = UIApplication.shared.keyWindow, keyWindow.bounds.width < 375.0 {
            buttonItemWidthConstraint.constant = 35.0
        }
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
    
    private func setupMarkdownToolbar() {
        let height: CGFloat = Constant.markdownToolbarHeight
        markdownToolbar.layer.cornerRadius = height / 2
        
        toolbarAccessoryView.addSubview(markdownToolbar)
        markdownToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[toolbar]-|", options: [], metrics: nil, views: ["toolbar": markdownToolbar])
        NSLayoutConstraint.activate(h)
        markdownToolbar.heightAnchor.constraint(equalToConstant: height).isActive = true
        markdownToolbar.topAnchor.constraint(equalTo: toolbarAccessoryView.topAnchor).isActive = true
        
        markdownCoordinator.configure(textView: editor, markdownToolbar: markdownToolbar)
    }
    
    private func fitsImageView(with image: UIImage?) {
        
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
        nav.view.layer.cornerRadius = 8.0
        nav.view.clipsToBounds = true
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
            size = CGSize(width: view.bounds.width - 70.0, height: 300.0)
        } else {
            size = CGSize(width: view.bounds.width - 80.0, height: 250.0)
        }
        
        let shadow = PopoverPresentationShadow(radius: 32.0, color: UIColor.black.withAlphaComponent(0.3))
        let context = PopoverPresentationContext(presentedContentSize: size, cornerRadius: 16.0, chromeAlpha: 0.0, shadow: shadow)
        self.popoverTransitioningDelegate = PopoverTransitioningDelegate(presentationContext: context)
        
        viewController.transitioningDelegate = popoverTransitioningDelegate
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func handleDismiss(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true) { [weak self] in
            self?.view.center.y += Defaults.statusBarHeight
            completion?()
        }
    }
}

// MARK: - Locating

extension NewFeedViewController {
    
    private func tryLocating(_ locate: Bool) -> Observable<Bool> {
        if !locate {
            return Observable.just(false)
        }
        
        return Observable.create { [weak self] observer -> Disposable in
            self?.hi.propose(for: .location(.whenInUse),
                             agreed: {
                                observer.onNext(true)
            }, rejected: {
                observer.onNext(false)
            })
            return Disposables.create()
        }
    }
    
    private func onLocating(_ locate: Bool) -> Observable<Result<LocationInfo?>> {
        if !locate {
            return Observable.just(.success(nil))
        }
        return Observable.create { observer -> Disposable in
            let service = LocationService.shared
            service.turnOn()
            
            service.didLocateHandler = { result in
                observer.onNext(result.map { LocationInfo(address: $0, coordinate: $1) })
            }
            
            return Disposables.create {
                service.turnOff()
            }
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
