//
//  PhotoEditingViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 07/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

enum AspectRatioPreset: Int {
    case original
    case square // 1 x 1
    case _2x3 // 2 x 3
    case _3x2 // 3 x 2
    case _4x3 // 4 x 3
    case _3x4 // 3 x 4
    case _5x3 // 5 x 3
    case _3x5 // 3 x 5
    case _5x4 // 5 x 4
    case _4x5 // 4 x 5
    case _7x5 // 7 x 5
    case _5x7 // 5 x 7
    case _16x9 // 16 x 9
    case _9x16 // 9 x 16
    case custom
    
    var size: CGSize {
        let aspectRatio: CGSize
        switch self {
        case .original:
            aspectRatio = CGSize.zero
        case .square:
            aspectRatio = CGSize(width: 1.0, height: 1.0)
        case ._3x2:
            aspectRatio = CGSize(width: 3.0, height: 2.0)
        case ._2x3:
            aspectRatio = CGSize(width: 2.0, height: 3.0)
        case ._4x3:
            aspectRatio = CGSize(width: 4.0, height: 3.0)
        case ._3x4:
            aspectRatio = CGSize(width: 3.0, height: 4.0)
        case ._5x3:
            aspectRatio = CGSize(width: 5.0, height: 3.0)
        case ._3x5:
            aspectRatio = CGSize(width: 3.0, height: 5.0)
        case ._5x4:
            aspectRatio = CGSize(width: 5.0, height: 4.0)
        case ._4x5:
            aspectRatio = CGSize(width: 4.0, height: 5.0)
        case ._7x5:
            aspectRatio = CGSize(width: 7.0, height: 5.0)
        case ._5x7:
            aspectRatio = CGSize(width: 5.0, height: 7.0)
        case ._16x9:
            aspectRatio = CGSize(width: 16.0, height: 9.0)
        case ._9x16:
            aspectRatio = CGSize(width: 9.0, height: 16.0)
        case .custom:
            aspectRatio = CGSize.zero
        }
        return aspectRatio
    }
    
    var reversedSize: CGSize {
        return CGSize(width: size.height, height: size.width)
    }
}

extension AspectRatioPreset: Namable {
    
    var named: String {
        switch self {
        case .original: return "original"
        case .square: return "1:1"
        case ._3x2: return "3:2"
        case ._2x3: return "2:3"
        case ._4x3: return "4:3"
        case ._3x4: return "3:4"
        case ._5x3: return "5:3"
        case ._3x5: return "3:5"
        case ._5x4: return "5:4"
        case ._4x5: return "4:5"
        case ._7x5: return "7:5"
        case ._5x7: return "5:7"
        case ._16x9: return "16:9"
        case ._9x16: return "9:16"
        case .custom: return "custom"
        }
    }
}

enum PhotoEditingViewControllerToolbarPosition {
    case top
    case bottom
}

///------------------------------------------------
/// @name Delegate
///------------------------------------------------

@objc
protocol PhotoEditingViewControllerDelegate: NSObjectProtocol {
    
    /**
     Called when the user has committed the crop action, and provides
     just the cropping rectangle.
     
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    @objc
    optional func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropImageToRect cropRect: CGRect, angle: Int)
    
    /**
     Called when the user has committed the crop action, and provides
     both the original image with crop co-ordinates.
     
     @param image The newly cropped image.
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    @objc
    optional func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int)
    
    /**
     If the cropping style is set to circular, implementing this delegate will return a circle-cropped version of the selected
     image, as well as it's cropping co-ordinates
     
     @param image The newly cropped image, clipped to a circle shape
     @param cropRect A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
     @param angle The angle of the image when it was cropped
     */
    @objc
    optional func photoEditingViewController(_ viewController: PhotoEditingViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int)
    
    /**
     If implemented, when the user hits cancel, or completes a
     UIActivityViewController operation, this delegate will be called,
     giving you a chance to manually dismiss the view controller
     */
    @objc
    optional func photoEditingViewController(_ viewController: PhotoEditingViewController, didFinishCancelled cancelled: Bool)
}

class PhotoEditingViewController: UIViewController {
    
    
    /**
     The original, uncropped image that was passed to this controller.
     */
    private(set) var image: UIImage
    
    /**
     The view controller's delegate that will return the resulting
     cropped image, as well as crop information
     */
    var delegate: PhotoEditingViewControllerDelegate?
    
    /**
     If true, when the user hits 'Done', a UIActivityController will appear
     before the view controller ends.
     */
    var showActivitySheetOnDone: Bool = false
    
    /**
     The crop view managed by this view controller.
     */
    private(set) lazy var cropView: CropView = {
        let view = CropView(image: self.image, croppingStyle: self.croppingStyle)
        view.delegate = self
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    /**
     In the coordinate space of the image itself, the region that is currently
     being highlighted by the crop box.
     
     This property can be set before the controller is presented to have
     the image 'restored' to a previous cropping layout.
     */
    var imageCropFrame: CGRect {
        get {
            return cropView.imageCropFrame
        }
        set {
            cropView.imageCropFrame = newValue
        }
    }
    
    /**
     The angle in which the image is rotated in the crop view.
     This can only be in 90 degree increments (eg, 0, 90, 180, 270).
     
     This property can be set before the controller is presented to have
     the image 'restored' to a previous cropping layout.
     */
    var angle: Int {
        get {
            return cropView.angle
        }
        set {
            cropView.angle = newValue
        }
    }
    
    /**
     The toolbar view managed by this view controller.
     */
    private(set) lazy var toolbar: PhotoEditingToolbar = {
        let toolbar = PhotoEditingToolbar(frame: self.frameForToolbar(verticalLayout: true))
        //toolbar.isHidden = true
        return toolbar
    }()
    
    /**
     The cropping style of this particular crop view controller
     */
    private(set) var croppingStyle: CropViewCroppingStyle
    
    private(set) var selectingFilter: Filter = .none
    
    /**
     A choice from one of the pre-defined aspect ratio presets
     */
    var aspectRatioPreset: AspectRatioPreset = .original
    
    /**
     A CGSize value representing a custom aspect ratio, not listed in the presets.
     E.g. A ratio of 4:3 would be represented as (CGSize){4.0f, 3.0f}
     */
    var customAspectRatio: CGSize = .zero {
        didSet {
            setAspectRatioPreset(.custom, animated: false)
        }
    }
    
    /**
     If true, while it can still be resized, the crop box will be locked to its current aspect ratio.
     
     If this is set to YES, and `resetAspectRatioEnabled` is set to NO, then the aspect ratio
     button will automatically be hidden from the toolbar.
     
     Default is NO.
     */
    var isAspectRatioLockEnabled: Bool {
        get {
            return self.cropView.isAspectRatioLockEnabled
        }
        set {
            self.toolbar.isFilterButtonGlowing = newValue
            self.cropView.isAspectRatioLockEnabled = newValue
            self.isAspectRatioPickerButtonHidden = newValue && !self.isResetAspectRatioEnabled
        }
    }
    
    /**
     If true, tapping the reset button will also reset the aspect ratio back to the image
     default ratio. Otherwise, the reset will just zoom out to the current aspect ratio.
     
     If this is set to NO, and `aspectRatioLockEnabled` is set to YES, then the aspect ratio
     button will automatically be hidden from the toolbar.
     
     Default is YES
     */
    var isResetAspectRatioEnabled: Bool = true {
        didSet {
            cropView.isResetAspectRatioEnabled = isResetAspectRatioEnabled
            isAspectRatioPickerButtonHidden = (!isResetAspectRatioEnabled && isAspectRatioLockEnabled)
        }
    }
    
    /**
     The position of the Toolbar the default value is `PhotoEditingViewControllerToolbarPosition`.
     */
    var toolbarPosition: PhotoEditingViewControllerToolbarPosition = .bottom
    
    /**
     When enabled, hides the rotation button, as well as the alternative rotation
     button visible when `isRotateButtonsHidden` is set to YES.
     
     Default is NO.
     */
    var isRotateButtonHidden: Bool {
        get {
            return toolbar.isRotateButtonHidden
        }
        set {
            self.toolbar.isRotateButtonHidden = newValue
        }
    }
    
    /**
     When enabled, hides the 'Aspect Ratio Picker' button on the toolbar.
     
     Default is NO.
     */
    var isAspectRatioPickerButtonHidden: Bool {
        get {
            return toolbar.isRatioBarHidden
        }
        set {
            toolbar.isRatioBarHidden = newValue
        }
    }
    
    /**
     If `showActivitySheetOnDone` is true, then these activity items will
     be supplied to that UIActivityViewController in addition to the
     `ActivityCroppedImageProvider` object.
     */
    var activityItems: [ActivityCroppedImageProvider] = []
    
    /**
     If `showActivitySheetOnDone` is true, then you may specify any
     custom activities your app implements in this array. If your activity requires
     access to the cropping information, it can be accessed in the supplied
     `ActivityCroppedImageProvider` object
     */
    var applicationActivities: [UIActivity] = []
    
    /**
     If `showActivitySheetOnDone` is true, then you may expliclty
     set activities that won't appear in the share sheet here.
     */
    var excludedActivityTypes: [UIActivityType] = []
    
    var contentInset: UIEdgeInsets = .zero
    
    // MARK: - Private
    
    private var prepareForTransitionHandler: (() -> Void)?
    
    /* Transition animation controller */
    private var transitionController = PhotoEditingViewControllerTransitioning()
    private var isInTransition: Bool = false
    private var isInitialedLayout: Bool = false
    
    private var isNavigationBarHidden: Bool = false
    private var isToolbarHidden: Bool = false
    
    private struct Constant {
        static let toolbarHeight: CGFloat = PhotoEditingToolbar.toolbarHeight
    }
    
    ///------------------------------------------------
    /// @name Object Creation
    ///------------------------------------------------
    
    /**
     Creates a new instance of a crop view controller with the supplied image and cropping style
     
     @param style The cropping style that will be used with this view controller (eg, rectangular, or circular)
     @param image The image that will be cropped
     */
    init(image: UIImage, croppingStyle: CropViewCroppingStyle = .default) {
        
        self.image = image
        self.croppingStyle = croppingStyle
        
        super.init(nibName: nil, bundle: nil)
        
        //self.modalTransitionStyle = .crossDissolve
        
        //self.modalPresentationStyle = .fullScreen
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Resets object of PhotoEditingViewController class as if user pressed reset button in the bottom bar themself
     */
    func resetCropViewLayout() {
        let animated = (cropView.angle == 0)
        
        if isResetAspectRatioEnabled {
            isAspectRatioLockEnabled = false
        }
        
        cropView.resetLayoutToDefault(animated: animated)
    }
    
    /**
     Set the aspect ratio to be one of the available preset options. These presets have specific behaviour
     such as swapping their dimensions depending on portrait or landscape sized images.
     
     @param aspectRatioPreset The aspect ratio preset
     @param animated Whether the transition to the aspect ratio is animated
     */
    func setAspectRatioPreset(_ preset: AspectRatioPreset, animated: Bool) {
        
        self.aspectRatioPreset = preset
        
        var aspectRatio = preset.size
       
        if preset == .custom {
            aspectRatio = customAspectRatio
        }
        
        //If the image is a portrait shape, flip the aspect ratio to match
        if aspectRatioPreset != .custom
            && cropView.isCropBoxAspectRatioPortrait && !isAspectRatioLockEnabled {
            let width = aspectRatio.width
            aspectRatio.width = aspectRatio.height
            aspectRatio.height = width
        }
        
        cropView.setAspectRatio(aspectRatio, animated: animated)
    }
    
    /**
     Play a custom animation of the target image zooming to its position in
     the crop controller while the background fades in. Additionally, if you're
     'restoring' to a previous crop setup, this method lets you provide a previously
     cropped copy of the image, and the previous crop settings to transition back to
     where the user would have left off.
     
     @param viewController The parent controller that this view controller would be presenting from.
     @param image The previously cropped image that can be used in the transition animation.
     @param fromView A view that's frame will be used as the origin for this animation. Optional if `fromFrame` has a value.
     @param fromFrame In the screen's coordinate space, the frame from which the image should animate from.
     @param angle The rotation angle in which the image was rotated when it was originally cropped.
     @param toFrame In the image's coordinate space, the previous crop frame that created the previous crop
     @param setup A block that is called just before the transition starts. Recommended for hiding any necessary image views.
     @param completion A block that is called once the transition animation is completed.
     */
    func presentAnimatedFromParentViewController(_ viewController: UIViewController,
                                                 fromImage: UIImage? = nil,
                                                 fromView: UIView?,
                                                 fromFrame: CGRect,
                                                 angle: Int = 0,
                                                 toImageFrame toFrame: CGRect = .zero,
                                                 setup: (() -> Void)?,
                                                 completion: (() -> Void)? = nil) {
        
        transitionController.image = fromImage ?? self.image
        transitionController.fromFrame = fromFrame
        transitionController.fromView = fromView
        prepareForTransitionHandler = setup
        
        if angle != 0 || !toFrame.isEmpty {
            self.angle = angle
            imageCropFrame = toFrame
        }
        
        viewController.present(self, animated: true) { [weak self] in
            
            completion?()
            
            guard let sSelf = self else { return }
            
            sSelf.cropView.setCroppingViewsHidden(false, animated: true)
            if !fromFrame.isEmpty {
                sSelf.cropView.setGridOverlayHidden(false, animated: true)
            }
        }
    }
    
    /**
     Play a custom animation of the supplied cropped image zooming out from
     the cropped frame to the specified frame as the rest of the content fades out.
     If any view configurations need to be done before the animation starts,
     
     @param viewController The parent controller that this view controller would be presenting from.
     @param image The resulting 'cropped' image. If supplied, will animate out of the crop box zone. If nil, the default image will entirely zoom out
     @param toView A view who's frame will be used to establish the destination frame
     @param frame The target frame that the image will animate to
     @param setup A block that is called just before the transition starts. Recommended for hiding any necessary image views.
     @param completion A block that is called once the transition animation is completed.
     */
    func dismissAnimatedFromParentViewController(_ viewController: UIViewController,
                                                 withCroppedImage image: UIImage? = nil,
                                                 toView: UIView?,
                                                 toFrame: CGRect,
                                                 setup: (() -> Void)?,
                                                 completion: (() -> Void)?) {
        
        if let image = image {
            transitionController.image = image
            transitionController.fromFrame = self.cropView.convert(self.cropView._cropBoxFrame, to: self.view)
        } else {
            transitionController.image = self.image
            transitionController.fromFrame = self.cropView.convert(self.cropView.imageViewFrame, to: self.view)
        }
        
        transitionController.toView = toView
        transitionController.toFrame = toFrame
        prepareForTransitionHandler = setup
        
        viewController.dismiss(animated: true, completion: completion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let circularMode = (croppingStyle == .circular)
        
        cropView.frame = frameForCropView(verticalLayout: view.bounds.width < view.bounds.height)
        view.addSubview(cropView)
        
        //toolbar.frame = frameForToolbar(verticalLayout: view.bounds.width < view.bounds.height)
        toolbar.image = self.image.hi.resize(to: PhotoEditingToolbar.Constant.presetSize, for: .scaleAspectFill)
        toolbar.ratioButton.isEnabled = !circularMode
        toolbar.preset = circularMode ? .filter : .ratio
        view.addSubview(toolbar)

        toolbar.doneButtonTapped = { [weak self] in self?.doneButtonTapped() }
        toolbar.cancelButtonTapped = { [weak self] in self?.cancelButtonTapped() }
        
        toolbar.resetButtonTapped = { [weak self] in self?.resetCropViewLayout() }
        
        toolbar.filterAction = { [weak self] in self?.selectedFilter($0) }
        toolbar.ratioAction = { [weak self] in self?.selectedRatio($0) }
        
        toolbar.rotateButtonTapped = { [weak self] in self?.rotateCropViewCounterclockwise() }
        
        toolbar.isRatioBarHidden = isAspectRatioPickerButtonHidden || circularMode
        toolbar.isRotateButtonHidden = isRotateButtonHidden && !circularMode
        
        //transitioningDelegate = self
        view.backgroundColor = cropView.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if animated {
            isInTransition = true
            setNeedsStatusBarAppearanceUpdate()
        }
        
        if let navigationController = navigationController {
            isNavigationBarHidden = navigationController.isNavigationBarHidden
            isToolbarHidden = navigationController.isToolbarHidden
            
            navigationController.setNavigationBarHidden(true, animated: animated)
            navigationController.setToolbarHidden(true, animated: animated)
            
            //modalTransitionStyle = .coverVertical
        } else {
            cropView.setBackgroundImageViewHidden(true, animated: false)
        }
        
        if aspectRatioPreset != .original {
            setAspectRatioPreset(aspectRatioPreset, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isInTransition = false
        
        cropView.isSimpleRenderMode = false
        
        if animated && !UIApplication.shared.isStatusBarHidden {
            
            UIView.animate(withDuration: 0.3) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
            
            if cropView.isGridOverlayHidden {
                cropView.setGridOverlayHidden(false, animated: true)
            }
            
            if navigationController == nil {
                cropView.setBackgroundImageViewHidden(false, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isInTransition = true
        
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: animated)
        navigationController?.setToolbarHidden(isToolbarHidden, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isInTransition = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return navigationController == nil ? .default : .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        if let navigationController = navigationController {
            return navigationController.prefersStatusBarHidden
        }
        
        if let presentingViewController = presentingViewController, presentingViewController.prefersStatusBarHidden {
            return true
        }
        
        var hidden = true
        hidden = hidden && !(isInTransition)
        hidden = hidden && !(self.view.superview == nil)
        
        return hidden
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let verticalLayout = view.bounds.width < view.bounds.height
        cropView.frame = frameForCropView(verticalLayout: verticalLayout)
        cropView.moveCroppedContentToCenter(animated: false)
        
//        UIView.performWithoutAnimation {
//            self.toolbar.statusBarVisible = (self.toolbarPosition == .top && !self.prefersStatusBarHidden)
//            self.toolbar.frame = self.frameForCropView(verticalLayout: verticalLayout)
//            self.toolbar.setNeedsLayout()
//        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard navigationController == nil, modalTransitionStyle != .coverVertical else {
            return nil
        }
        
        cropView.isSimpleRenderMode = true
        
        transitionController.prepareForTransitionHandler = { [weak self] in
            guard let sSelf = self else { return }
            
            let transitioning = sSelf.transitionController
            transitioning.toFrame = sSelf.cropView.convert(sSelf.cropView._cropBoxFrame, to: sSelf.view)
            if !transitioning.fromFrame.isEmpty || transitioning.fromView != nil {
                sSelf.cropView.isCroppingViewsHidden = true
            }
            
            sSelf.prepareForTransitionHandler?()
            sSelf.prepareForTransitionHandler = nil
        }
        
        transitionController.isDismissing = false
        
        return transitionController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard navigationController == nil, modalTransitionStyle != .coverVertical else {
            return nil
        }
        
        transitionController.prepareForTransitionHandler = { [weak self] in
            guard let sSelf = self else { return }
            
            let transitioning = sSelf.transitionController
            if !transitioning.toFrame.isEmpty || transitioning.toView != nil {
                sSelf.cropView.isCroppingViewsHidden = true
            } else {
                sSelf.cropView.isSimpleRenderMode = true
            }
            
            sSelf.prepareForTransitionHandler?()
        }
        
        transitionController.isDismissing = true
        
        return transitionController
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
            
            cropView.prepareForRotation()
            cropView.frame = self.frameForCropView(verticalLayout: !UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
            cropView.isSimpleRenderMode = true
            cropView.isInternalLayoutDisabled = true
        }
        
        func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
            
            cropView.frame = self.frameForCropView(verticalLayout: !UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
            cropView.performRelayoutForRotation()
        }
        
        func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
            
            cropView.setSimpleRenderMode(false, animated: true)
            cropView.isInternalLayoutDisabled = false
        }
        
        var orientation = UIInterfaceOrientation.portrait
        
        if self.view.bounds.width < size.width {
            orientation = .landscapeLeft
        }
        
        willRotate(to: orientation, duration: coordinator.transitionDuration)
        coordinator.animate(alongsideTransition: { (context) in
            willAnimateRotation(to: orientation, duration: coordinator.transitionDuration)
        }, completion: { context in
            didRotate(from: orientation)
        })
    }
    
    // MARK: - Private method
    
    private func frameForCropView(verticalLayout: Bool) -> CGRect {
        //On an iPad, if being presented in a modal view controller by a UINavigationController,
        //at the time we need it, the size of our view will be incorrect.
        //If this is the case, derive our view size from our parent view controller instead
        
        let bounds: CGRect
        
        if let parent = self.parent {
            bounds = parent.view.bounds
        } else {
            bounds = self.view.bounds
        }
        
        var frame: CGRect = .zero
        if !verticalLayout {
            frame.origin.x = 44.0
            frame.origin.y = 0.0
            frame.size.width = bounds.width - 44.0
            frame.size.height = bounds.height
            
        } else {
            frame.origin.x = 0.0
            
            if toolbarPosition == .bottom {
                frame.origin.y = 0.0
            } else {
                frame.origin.y = Constant.toolbarHeight
            }
            
            frame.size.width = bounds.width
            frame.size.height = bounds.height - Constant.toolbarHeight - contentInset.bottom
        }
        
        return frame
    }
    
    /* Button callback */
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func doneButtonTapped() {
        
        let croppingFrame = cropView.imageCropFrame
        let angle = cropView.angle
        
        let filteredImage = self.image.hi.apply(selectingFilter)
        
        //If desired, when the user taps done, show an activity sheet
        if showActivitySheetOnDone {
            let imageItem = ActivityCroppedImageProvider(image: filteredImage, cropFrame: croppingFrame, angle: angle, circular: (croppingStyle == .circular))
            
            let attributes = CroppedImageAttributes(croppedFrame: croppingFrame, angle: angle, originalImageSize: image.size)
            
            var items = [imageItem, attributes] as [Any]
            
            items.append(activityItems)
            
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: self.applicationActivities)

            activityController.excludedActivityTypes = excludedActivityTypes
            
            //activityController.modalPresentationStyle = .popover
            activityController.popoverPresentationController?.sourceView = self.toolbar
            activityController.popoverPresentationController?.sourceRect = self.toolbar.doneButtonFrame
            
            present(activityController, animated: true, completion: nil)
            
            activityController.completionWithItemsHandler = { [weak self] activityType, completed, _, _ in
                
                guard completed else { return }
                
                if let sSelf = self, let delegate = self?.delegate, delegate.responds(to: #selector(PhotoEditingViewControllerDelegate.photoEditingViewController(_:didFinishCancelled:))) {
                    self?.delegate?.photoEditingViewController!(sSelf, didFinishCancelled: false)
                } else {
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    activityController.completionWithItemsHandler = nil
                }
            }
        } else {
            
            guard let delegate = delegate else {
                presentingViewController?.dismiss(animated: true, completion: nil)
                return
            }
        
            //If the delegate that only supplies crop data is provided, call it
            if delegate.responds(to: #selector(PhotoEditingViewControllerDelegate.photoEditingViewController(_:didCropImageToRect:angle:))) {
                delegate.photoEditingViewController!(self, didCropImageToRect: croppingFrame, angle: angle)
            } else if croppingStyle == .circular, delegate.responds(to: #selector(PhotoEditingViewControllerDelegate.photoEditingViewController(_:didCropToCircularImage:withRect:angle:))) {
                
                let croppedImage = filteredImage.hi.cropped(with: croppingFrame, angle: angle, circularClip: true)
                
                //dispatch on the next run-loop so the animation isn't interuppted by the crop operation
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(0.03))) {
                    delegate.photoEditingViewController!(self, didCropToCircularImage: croppedImage, withRect: croppingFrame, angle: angle)
                }
            } else if delegate.responds(to: #selector(PhotoEditingViewControllerDelegate.photoEditingViewController(_:didCropToImage:withRect:angle:))) {
                //If the delegate that requires the specific cropped image is provided, call it
                let croppedImage: UIImage
                
                if angle == 0 && croppingFrame.equalTo(CGRect(origin: .zero, size: self.image.size)) {
                    // original
                    croppedImage = filteredImage
                } else {
                    croppedImage = filteredImage.hi.cropped(with: croppingFrame, angle: angle, circularClip: false)
                }
                
                //dispatch on the next run-loop so the animation isn't interuppted by the crop operation
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(0.03))) {
                    delegate.photoEditingViewController!(self, didCropToImage: croppedImage, withRect: croppingFrame, angle: angle)
                }
            }
        }
    }
    
    private func selectedFilter(_ filter: Filter) {
        selectingFilter = filter
        
        cropView.transform(with: filter)
    }
    
    private func selectedRatio(_ ratio: AspectRatioPreset) {
        setAspectRatioPreset(ratio, animated: true)
    }

    private func rotateCropViewClockwise() {
        cropView.rotateImageNinetyDegrees(animated: true, clockwise: true)
    }
    
    private func rotateCropViewCounterclockwise() {
        cropView.rotateImageNinetyDegrees(animated: true, clockwise: false)
    }
    
    /* View layout */
    private func frameForToolbar(verticalLayout: Bool) -> CGRect {
        
        var frame = CGRect.zero
        
        if !verticalLayout {
            frame.origin.x = 0.0
            frame.origin.y = 0.0
            frame.size.width = 44.0
            frame.size.height = self.view.frame.height
        } else {
            frame.origin.x = 0.0
            
            if self.toolbarPosition == .bottom {
                frame.origin.y = self.view.bounds.height - Constant.toolbarHeight - contentInset.bottom
            } else {
                frame.origin.y = 0
            }
            
            frame.size.width = self.view.bounds.width
            frame.size.height = Constant.toolbarHeight
            
            // If the bar is at the top of the screen and the status bar is visible, account for the status bar height
            if self.toolbarPosition == .top && self.prefersStatusBarHidden == false {
                frame.size.height = Constant.toolbarHeight + 20.0
            }
        }
        
        return frame
    }
}

extension PhotoEditingViewController: CropViewDelegate {
   
    func cropViewDidBecomeResettable(cropView: CropView) {
        toolbar.resetButtonEnabled = true
    }
    
    func cropViewDidBecomeNonResettable(cropView: CropView) {
        toolbar.resetButtonEnabled = false
    }
}
