//
//  CropView.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 01/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol CropViewDelegate: class {
    func cropViewDidBecomeResettable(cropView: CropView)
    func cropViewDidBecomeNonResettable(cropView: CropView)
}

enum CropViewCroppingStyle {
    case `default`
    case circular
}

enum CropViewOverlayEdge: Int {
    case none
    
    case topLeft
    case top
    case topRight
    
    case right
    
    case bottomRight
    case bottom
    case bottomLeft
    
    case left
}

private let cropViewPadding: CGFloat = 14.0
private let cropTimerDuration: TimeInterval = 0.8
private let minimumBoxSize: CGFloat = 42.0
private let circularPathRadius: CGFloat = 300.0

class CropView: UIView {

    // MARK: Property
    /**
     The image that the crop view is displaying. This cannot be changed once the crop view is instantiated.
     */
    
    private(set) var image: UIImage?
    
    /**
     The cropping style of the crop view (eg, rectangular or circular)
     */
    
    private(set) var croppingStyle: CropViewCroppingStyle = .default
    
    /**
     A grid view overlaid on top of the foreground image view's container.
     */
    private(set) lazy var gridOverlayView: CropOverlayView = {
        let overlayView = CropOverlayView(frame: .zero)
        overlayView.setGridHidden(true, animated: false)
        overlayView.isUserInteractionEnabled = false
        return overlayView
    }()
    
    /**
     A delegate object that receives notifications from the crop view
     */
    weak var delegate: CropViewDelegate?
    
    /**
     If false, the user cannot resize the crop box frame using a pan gesture from a corner.
     Default vaue is YES.
     */
    var isCropBoxResizeEnabled = true {
        didSet {
            gridPanGestureRecognizer.isEnabled = isCropBoxResizeEnabled
        }
    }
    
    /**
     Whether the user has manipulated the crop view to the point where it can be reset
     */
    var canBeReset = false {
        didSet {
            if canBeReset {
                delegate?.cropViewDidBecomeResettable(cropView: self)
            } else {
                delegate?.cropViewDidBecomeNonResettable(cropView: self)
            }
        }
    }
    
    func setCropBoxFrame(_ cropBoxFrame: CGRect) {
        
        //Upon init, sometimes the box size is still 0, which can result in CALayer issues
        guard cropBoxFrame != _cropBoxFrame, cropBoxFrame.width > CGFloat.ulpOfOne, cropBoxFrame.height > CGFloat.ulpOfOne else { return }
        
        var boxFrame = cropBoxFrame
        
        let contentFrame = self.contentBounds
        let xOrigin = ceil(contentFrame.origin.x)
        let xDelta = boxFrame.origin.x - xOrigin
        
        boxFrame.origin.x = max(boxFrame.origin.x, xOrigin).rounded(.up)
        if xDelta < -CGFloat.ulpOfOne {
            boxFrame.size.width += xDelta
        }
        
        let yOrigin = ceil(contentFrame.origin.y)
        let yDelta = boxFrame.origin.y - yOrigin
        boxFrame.origin.y = max(boxFrame.origin.y, yOrigin).rounded(.up)
        if yDelta < -CGFloat.ulpOfOne {
            boxFrame.size.height += yDelta
        }
        
        let maxWidth = contentFrame.width + contentFrame.origin.x - boxFrame.origin.x
        boxFrame.size.width = min(boxFrame.width, maxWidth).rounded(.up)
        
        let maxHeight = contentFrame.height + contentFrame.origin.y - boxFrame.origin.y
        boxFrame.size.height = min(boxFrame.height, maxHeight).rounded(.up)
        
        boxFrame.size.width = max(boxFrame.width, minimumBoxSize)
        boxFrame.size.height = max(boxFrame.height, minimumBoxSize)
        
        // here
        _cropBoxFrame = boxFrame
        
        foregroundContainerView.frame = boxFrame
        gridOverlayView.frame = boxFrame
        
        let scale = boxFrame.width / circularPathRadius
        circularMaskLayer.transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0)
        
        scrollView.contentInset = UIEdgeInsets(top: boxFrame.minY, left: boxFrame.minX, bottom: self.bounds.maxY - boxFrame.maxY, right: self.bounds.maxX - boxFrame.maxX)
        
        let imageSize = backgroundContainerView.bounds.size
        let minScale = max(boxFrame.height / imageSize.height, boxFrame.width / imageSize.width)
        scrollView.minimumZoomScale = minScale
        
        var size = scrollView.contentSize
        size.width = size.width.rounded(.up)
        size.height = size.height.rounded(.up)
        
        scrollView.contentSize = size
        
        scrollView.zoomScale = scrollView.zoomScale
        
        matchForegroundToBackground()
    }
    
    /**
     The frame of the cropping box in the coordinate space of the crop view
     */
    private(set) var _cropBoxFrame: CGRect = .zero
    
    /**
     The frame of the entire image in the backing scroll view
     */
    var imageViewFrame: CGRect {
        var frame = CGRect.zero
        frame.origin.x = -self.scrollView.contentOffset.x
        frame.origin.y = -self.scrollView.contentOffset.y
        frame.size = self.scrollView.contentSize
        return frame
    }
    
    /**
     Inset the workable region of the crop view in case in order to make space for accessory views
     */
    var cropRegionInsets: UIEdgeInsets = .zero
    
    /**
     Disable the dynamic translucency in order to smoothly relayout the view
     */
    var isSimpleRenderMode = false
    
    /**
     When performing manual content layout (such as during screen rotation), disable any internal layout
     */
    var isInternalLayoutDisabled = false
    
    /**
     A width x height ratio that the crop box will be rescaled to (eg 4:3 is {4.0f, 3.0f})
     Setting it to CGSizeZero will reset the aspect ratio to the image's own ratio.
     */
    var aspectRatio: CGSize = .zero
    
    /**
     When the cropping box is locked to its current aspect ratio (But can still be resized)
     */
    var isAspectRatioLockEnabled = false
    
    /**
     When the user taps 'reset', whether the aspect ratio will also be reset as well
     Default is YES
     */
    var isResetAspectRatioEnabled = true
    
    /**
     True when the height of the crop box is bigger than the width
     */
    private(set) var isCropBoxAspectRatioPortrait = false
    
    /**
     The rotation angle of the crop view (Will always be negative as it rotates in a counter-clockwise direction)
     */
    var angle = 0
    
    /**
     Hide all of the crop elements for transition animations
     */
    var isCroppingViewsHidden = false
    
    /**
     In relation to the coordinate space of the image, the frame that the crop view is focusing on
     */
    var imageCropFrame: CGRect {
        get {
            let imageSize = self.imageSize
            let contentSize = self.scrollView.contentSize
            let cropBoxFrame = self._cropBoxFrame
            let contentOffset = self.scrollView.contentOffset
            let edgeInsets = self.scrollView.contentInset
            
            var frame = CGRect.zero
            frame.origin.x = floor((contentOffset.x + edgeInsets.left) * (imageSize.width / contentSize.width))
            frame.origin.x = max(0, frame.origin.x);
            
            frame.origin.y = floor((contentOffset.y + edgeInsets.top) * (imageSize.height / contentSize.height))
            frame.origin.y = max(0, frame.origin.y);
            
            frame.size.width = ceil(cropBoxFrame.size.width * (imageSize.width / contentSize.width))
            frame.size.width = min(imageSize.width, frame.size.width);
            
            frame.size.height = ceil(cropBoxFrame.size.height * (imageSize.height / contentSize.height))
            frame.size.height = min(imageSize.height, frame.size.height)
            
            return frame
        }
        set {
            if (self.superview == nil) {
                self.restoreImageCropFrame = newValue
            } else {
                self.updateTo(imageCropFrame: newValue)
            }
        }
    }
    
    /**
     Set the grid overlay graphic to be hidden
     */
    var isGridOverlayHidden = false
    
    // MARK: Private 
    /* Views */
    private lazy var backgroundImageView: UIImageView = UIImageView(image: self.image)     /* The main image view, placed within the scroll view */
    private var backgroundContainerView: UIView!       /* A view which contains the background image view, to separate its transforms from the scroll view. */
    private lazy var foregroundImageView: UIImageView = UIImageView(image: self.image)     /* A copy of the background image view, placed over the dimming views */
    private lazy var foregroundContainerView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    /* A container view that clips the foreground image view to the crop box frame */
    
    /* The scroll view in charge of panning/zooming the image. */
    private lazy var scrollView: CropScrollView = {
        let scrollView = CropScrollView()
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    /* A semi-transparent grey view, overlaid on top of the background image */
    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = self.backgroundColor?.withAlphaComponent(0.35)
        view.isHidden = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /* A blur view that is made visible when the user isn't interacting with the crop view */
    private lazy var translucencyView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: self.translucencyEffect)
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.isHidden = false
        effectView.isUserInteractionEnabled = false
        return effectView
    }()
    
    /* The dark blur visual effect applied to the visual effect view. */
    private lazy var translucencyEffect: UIBlurEffect = {
        return UIBlurEffect(style: .dark)
    }()
    
    /* Managing the clipping of the foreground container into a circle */
    private lazy var circularMaskLayer: CAShapeLayer = CAShapeLayer()// {
        //return CAShapeLayer()
    //}()
    
    /* Gesture Recognizers */
    private lazy var gridPanGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer() /* The gesture recognizer in charge of controlling the resizing of the crop view */
    
    /* Crop box handling */
    private var applyInitialCroppedImageFrame = false /* No by default, when setting initialCroppedImageFrame this will be set to YES, and set back to NO after first application - so it's only done once */
    private var tappedEdge: CropViewOverlayEdge = .none /* The edge region that the user tapped on, to resize the cropping region */
    private var cropOriginFrame: CGRect = .zero     /* When resizing, this is the original frame of the crop box. */
    private var panOriginPoint: CGPoint = .zero     /* The initial touch point of the pan gesture recognizer */

    /* The timer used to reset the view after the user stops interacting with it */
    private var resetTimer: Timer?

    private var isEditing: Bool = false       /* Used to denote the active state of the user manipulating the content */
    private var isDisableForgroundMatching = false /* At times during animation, disable matching the forground image view to the background */
    
    /* Pre-screen-rotation state information */
    private var rotationContentOffset: CGPoint = .zero
    private var rotationContentSize: CGSize = .zero
    private var rotationBoundSize: CGSize = .zero
    
    /* View State information */
    /* Give the current screen real-estate, the frame that the scroll view is allowed to use */
    private var contentBounds: CGRect {
        var contentRect = CGRect.zero
        contentRect.origin.x = cropViewPadding + cropRegionInsets.left
        contentRect.origin.y = cropViewPadding + cropRegionInsets.top
        contentRect.size.width = bounds.width - ((cropViewPadding * 2) + cropRegionInsets.left + cropRegionInsets.right)
        contentRect.size.height = bounds.height - ((cropViewPadding * 2) + cropRegionInsets.top + cropRegionInsets.bottom)
        return contentRect
    }
    
    /* Given the current rotation of the image, the size of the image */
    private var imageSize: CGSize {
        guard let image = image else { return CGSize.zero }
        
        if (self.angle == -90 || self.angle == -270 || self.angle == 90 || self.angle == 270) {
            return CGSize(width: image.size.height, height: image.size.width)
        } else {
            return CGSize(width: image.size.width, height: image.size.height)
        }
    }
    
    /* True if an aspect ratio was explicitly applied to this crop view */
    private var hasAspectRatio: Bool {
        return aspectRatio.width > CGFloat.ulpOfOne && aspectRatio.height > CGFloat.ulpOfOne
    }
    
    /* 90-degree rotation state data */
    private var applyInitialRotatedAngle: Bool = false /* No by default, when setting initialRotatedAngle this will be set to YES, and set back to NO after first application - so it's only done once */
    private var cropBoxLastEditedSize: CGSize = .zero /* When performing 90-degree rotations, remember what our last manual size was to use that as a base */
    private var cropBoxLastEditedAngle: Int = 0 /* Remember which angle we were at when we saved the editing size */
    private var cropBoxLastEditedZoomScale: CGFloat = 0.0 /* Remember the zoom size when we last edited */
    private var cropBoxLastEditedMinZoomScale: CGFloat = 0.0 /* Remember the minimum size when we last edited. */
    private var isRotateAnimationInProgress: Bool = false   /* Disallow any input while the rotation animation is playing */
    
    /* Reset state data */
    private var originalCropBoxSize: CGSize = .zero /* Save the original crop box size so we can tell when the content has been edited */
    private var originalContentOffset = CGPoint.zero /* Save the original content offset so we can tell if it's been scrolled. */
    
    /* In iOS 9, a new dynamic blur effect became available. */
    private var dynamicBlurEffect: Bool {
        return UIDevice.current.systemVersion.compare("9.0") != .orderedAscending
    }
    
    /* If restoring to  a previous crop setting, these properties hang onto the
     values until the view is configured for the first time. */
    private var restoreAngle: Int = 0
    private var restoreImageCropFrame: CGRect = .zero
    
    // MARK: Method
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Create a new instance of the crop view with the specified image and cropping
     */
    init(image: UIImage, croppingStyle style: CropViewCroppingStyle = .default) {
        super.init(frame: CGRect.zero)
        
        self.image = image
        self.croppingStyle = style
        
        setup()
    }
    
    private func setup() {
        
        let circularMode = (croppingStyle == .circular)
        
        //View properties
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        
        applyInitialCroppedImageFrame = false

        isCropBoxResizeEnabled = !circularMode
        
        aspectRatio = circularMode ? CGSize(width: 1.0, height: 1.0) : CGSize.zero
        isResetAspectRatioEnabled = !circularMode
        
        //Scroll View properties
        
        addSubview(scrollView)
        
        scrollView.touchesBegan = { [weak self] in self?.startEditing() }
        scrollView.touchesEnded = { [weak self] in self?.startResetTimer() }
        
        //Background Image View
        backgroundImageView.layer.minificationFilter = kCAFilterTrilinear
        
        //Background container view
        backgroundContainerView = UIView(frame: backgroundImageView.frame)
        backgroundContainerView.addSubview(backgroundImageView)

        scrollView.addSubview(backgroundContainerView)
        
        //Grey transparent overlay view
        
        addSubview(overlayView)
        
        //Translucency View
        
        addSubview(translucencyView)
        
        // The forground container that holds the foreground image view
        addSubview(foregroundContainerView)
        
        foregroundImageView.layer.minificationFilter = kCAFilterTrilinear
        foregroundContainerView.addSubview(foregroundImageView)
        
        // The following setup isn't needed during circular cropping
        if circularMode {
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: circularPathRadius, height: circularPathRadius))
            circularMaskLayer.path = circlePath.cgPath
            foregroundContainerView.layer.mask = self.circularMaskLayer
            return
        }
        
        // The white grid overlay view
        gridOverlayView.frame = foregroundContainerView.frame
        addSubview(gridOverlayView)
        
        // The pan controller to recognize gestures meant to resize the grid view
        gridPanGestureRecognizer.delegate = self
        gridPanGestureRecognizer.addTarget(self, action: #selector(gridPanGestureRecognized(_:)))
        scrollView.panGestureRecognizer.require(toFail: gridPanGestureRecognizer)
        addGestureRecognizer(gridPanGestureRecognizer)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil  else {
            return
        }
        
        //Perform the initial layout of the image
        layoutInitialImage()
        
        //If the angle value was previously set before this point, apply it now
        if restoreAngle != 0 {
            angle = restoreAngle
            restoreAngle = 0
        }
        
        //If an image crop frame was also specified before creation, apply it now
        if !restoreImageCropFrame.isEmpty {
            imageCropFrame = restoreImageCropFrame
            restoreImageCropFrame = CGRect.zero
        }
        
        //Check if we performed any resetabble modifications
        checkForCanReset()
    }
    
    private func layoutInitialImage() {
        
        let imageSize = self.imageSize
        scrollView.contentSize = imageSize
        
        let bounds = contentBounds
        let boundsSize = bounds.size
        
        //work out the minimum scale of the object
        // Work out the size of the image to fit into the content bounds
        var scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        
        let scaledImageSize = CGSize(width: (imageSize.width * scale).rounded(.up), height: (imageSize.height * scale).rounded(.up))
        
        // If an aspect ratio was pre-applied to the crop view, use that to work out the minimum scale the image needs to be to fit
        var cropBoxSize = CGSize.zero
        
        if hasAspectRatio {
            let ratioScale = (aspectRatio.width / aspectRatio.height) //Work out the size of the width in relation to height
            let fullSizeRatio = CGSize(width: boundsSize.height * ratioScale, height: boundsSize.height)
            let fitScale = min(boundsSize.width / fullSizeRatio.width, boundsSize.height / fullSizeRatio.height)
            cropBoxSize = CGSize(width: fullSizeRatio.width * fitScale, height: fullSizeRatio.height * fitScale)
            
            scale = max(cropBoxSize.width / imageSize.width, cropBoxSize.height / imageSize.height)
        }
        
        //Whether aspect ratio, or original, the final image size we'll base the rest of the calculations off
        let scaledSize = CGSize(width: (imageSize.width * scale).rounded(.up), height: (imageSize.height * scale).rounded(.up))
        
        // Configure the scroll view
        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = 15.0
        
        //Set the crop box to the size we calculated and align in the middle of the screen
        var boxFrame = CGRect.zero
        boxFrame.size = hasAspectRatio ? cropBoxSize : scaledSize
        boxFrame.origin.x = bounds.origin.x + ((bounds.width - boxFrame.size.width) * 0.5).rounded(.up)
        boxFrame.origin.y = bounds.origin.y + ((bounds.height - boxFrame.size.height) * 0.5).rounded(.up)
        setCropBoxFrame(boxFrame)
        
        //set the fully zoomed out state initially
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.contentSize = scaledSize
        
        // If we ended up with a smaller crop box than the content, offset it in the middle
        if (boxFrame.width < scaledSize.width - CGFloat.ulpOfOne || boxFrame.size.height < scaledSize.height - CGFloat.ulpOfOne) {
            var offset = CGPoint.zero
            offset.x = -((scrollView.frame.width - scaledSize.width) * 0.5).rounded(.up)
            offset.y = -((scrollView.frame.height - scaledSize.height) * 0.5).rounded(.up)
            scrollView.contentOffset = offset
        }
        
        //save the current state for use with 90-degree rotations
        cropBoxLastEditedAngle = 0
        captureStateForImageRotation()
        
        //save the size for checking if we're in a resettable state
        originalCropBoxSize = isResetAspectRatioEnabled ? scaledImageSize : cropBoxSize
        originalContentOffset = scrollView.contentOffset
        
        checkForCanReset()
        matchForegroundToBackground()
    }
    
    private func checkForCanReset() {
        
        if self.angle != 0 { //Image has been rotated
            canBeReset = true
        } else if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale + CGFloat.ulpOfOne) { //image has been zoomed in
            canBeReset = true
        } else if Int((_cropBoxFrame.size.width).rounded(.up)) != Int((self.originalCropBoxSize.width).rounded(.up)) ||
            Int((_cropBoxFrame.size.height).rounded(.up)) != Int((self.originalCropBoxSize.height).rounded(.up))
        { //crop box has been changed
            canBeReset = true
        } else if Int((self.scrollView.contentOffset.x).rounded(.up)) != Int((self.originalContentOffset.x).rounded(.up)) ||
            Int((self.scrollView.contentOffset.y).rounded(.up)) != Int((self.originalContentOffset.y).rounded(.up))
        {
            canBeReset = true
        } else {
            canBeReset = false
        }
    }
   
    private func captureStateForImageRotation() {
        cropBoxLastEditedSize = _cropBoxFrame.size
        cropBoxLastEditedZoomScale = scrollView.zoomScale
        cropBoxLastEditedMinZoomScale = scrollView.minimumZoomScale
    }
    
    private func matchForegroundToBackground() {
        guard !isDisableForgroundMatching else { return }
        
        //We can't simply match the frames since if the images are rotated, the frame property becomes unusable
        foregroundImageView.frame = backgroundContainerView.superview?.convert(self.backgroundContainerView.frame, to: self.foregroundContainerView) ?? .zero
    }
    
    private func toggleTranslucencyViewVisible(_ visible: Bool) {
        if !dynamicBlurEffect {
            self.translucencyView.alpha = visible ? 1.0 : 0.0
        } else {
            self.translucencyView.effect = visible ? self.translucencyEffect : nil
        }
    }
    
    private func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else {
            return
        }
        
        self.isEditing = editing
        
        self.gridOverlayView.setGridHidden(!editing, animated: animated)
        
        if !editing {
            moveCroppedContentToCenter(animated: animated)
            captureStateForImageRotation()
            
            cropBoxLastEditedAngle = angle
        }
        
        if !animated {
            DispatchQueue.main.async {
                self.toggleTranslucencyViewVisible(!editing)
            }
        } else {
            let duration = editing ? 0.05 : 0.35
            var delay = editing ? 0.0 : 0.35
            
            if croppingStyle == .circular {
                delay = 0.0
            }
            
            DispatchQueue.main.async {
                UIView.animateKeyframes(withDuration: duration, delay: delay, options: [], animations: {
                    self.toggleTranslucencyViewVisible(!editing)
                }, completion: nil)
            }
        }
    }
    
    private func startEditing() {
        cancelResetTimer()
        setEditing(true, animated: true)
    }
    
    // --
    
    @objc
    private func gridPanGestureRecognized(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.location(in: self)
        
        switch sender.state {
        case .began:
            startEditing()
            panOriginPoint = point
            cropOriginFrame = _cropBoxFrame
            tappedEdge = cropEdge(forPoint: panOriginPoint)
        case .ended:
            startResetTimer()
        default:
            break
        }
        
        updateCropBoxFrame(gesturePoint: point)
    }
    
    private func updateCropBoxFrame(gesturePoint point: CGPoint) {
        var frame = _cropBoxFrame
        
        let originFrame = self.cropOriginFrame
        let contentFrame = self.contentBounds
        
        let x = max(contentFrame.origin.x, point.x)
        let y = max(contentFrame.origin.y, point.y)
        
        //The delta between where we first tapped, and where our finger is now
        var xDelta = ceil(x - panOriginPoint.x)
        var yDelta = ceil(y - panOriginPoint.y)
        
        //Current aspect ratio of the crop box in case we need to clamp it
        let aspectRatio = (originFrame.width / originFrame.height)
        
        //Depending on which corner we drag from, set the appropriate min flag to
        var aspectHozizontal = false
        var aspectVertical = false
        
        //ensure we can properly clamp the XY value of the box if it overruns the minimum size
        //(Otherwise the image itself will slide with the drag gesture)
        var clampMinFromTop = false
        var clampMinFromLeft = false
        
        switch tappedEdge {
        case .left:
            if isAspectRatioLockEnabled {
                aspectHozizontal = true
                xDelta = max(xDelta, 0)
                let scaleOrigin = CGPoint(x: originFrame.maxX, y: originFrame.midY)
                frame.size.height = frame.width / aspectRatio
                frame.origin.y = scaleOrigin.y - (frame.height * 0.5)
            }
            
            frame.origin.x = originFrame.origin.x + xDelta
            frame.size.width = originFrame.width - xDelta
            
            clampMinFromLeft = true
        case .right:
            if isAspectRatioLockEnabled {
                aspectHozizontal = true
                let scaleOrigin = CGPoint(x: originFrame.minX, y: originFrame.minY)
                frame.size.height = frame.width / aspectRatio
                frame.origin.y = scaleOrigin.y - (frame.height * 0.5)
                frame.size.width = originFrame.width + xDelta
                frame.size.width = min(frame.width, contentFrame.height * aspectRatio)
            } else {
                frame.size.width = originFrame.width + xDelta
            }
        case .bottom:
            if isAspectRatioLockEnabled {
                aspectVertical = true
                let scaleOrigin = CGPoint(x: originFrame.minX, y: originFrame.minY)
                frame.size.width = frame.height * aspectRatio
                frame.origin.x = scaleOrigin.x - (frame.width * 0.5)
                frame.size.height = originFrame.height + yDelta
                frame.size.height = min(frame.height, contentFrame.width / aspectRatio)
            } else {
                frame.size.height = originFrame.height + yDelta
            }
        case .top:
            if isAspectRatioLockEnabled {
                aspectVertical = true
                yDelta = max(0, yDelta)
                let scaleOrigin = CGPoint(x: originFrame.minX, y: originFrame.maxY)
                frame.size.width = frame.height * aspectRatio
                frame.origin.x = scaleOrigin.x - (frame.width * 0.5)
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.height - yDelta
            } else {
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.height - yDelta
            }
            clampMinFromTop = true
        case .topLeft:
            if isAspectRatioLockEnabled {
                xDelta = max(xDelta, 0)
                yDelta = max(yDelta, 0)
                
                let distance = CGPoint(x: 1.0 - (xDelta / originFrame.width), y: 1.0 - (yDelta / originFrame.height))
                
                let scale = (distance.x + distance.y) * 0.5
                
                frame.size.width =  ceil(originFrame.width * scale)
                frame.size.height = ceil(originFrame.height * scale)
                frame.origin.x = originFrame.origin.x + (originFrame.width - frame.width)
                frame.origin.y = originFrame.origin.y + (originFrame.width - frame.height)
                
                aspectVertical = true
                aspectHozizontal = true
            } else {
                frame.origin.x = originFrame.origin.x + xDelta
                frame.size.width = originFrame.width + xDelta
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.height - yDelta
            }
        
            clampMinFromTop = true
            clampMinFromLeft = true
            
        case .topRight:
            if isAspectRatioLockEnabled {
                xDelta = min(xDelta, 0)
                yDelta = max(yDelta, 0)
                
                let distance = CGPoint(x: 1.0 - ((-xDelta) / originFrame.width), y: 1.0 - (yDelta / originFrame.height))
                
                let scale = (distance.x + distance.y) * 0.5
                
                frame.size.width = ceil(originFrame.width * scale)
                frame.size.height = ceil(originFrame.height * scale)
                frame.origin.y = originFrame.origin.y + (originFrame.height - frame.height)
                
                aspectHozizontal = true
                aspectVertical = true
            } else {
                frame.size.width = originFrame.width + xDelta
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.height - yDelta
            }
            
            clampMinFromTop = true
        case .bottomLeft:
            if isAspectRatioLockEnabled {
                let distance = CGPoint(x: 1.0 - (xDelta / originFrame.width), y: 1.0 - (-yDelta / originFrame.height))
                
                let scale = (distance.x + distance.y) * 0.5
                
                frame.size.width = ceil(originFrame.width * scale)
                frame.size.height = ceil(originFrame.height * scale)
                frame.origin.x = originFrame.maxX - frame.width
                
                aspectVertical = true
                aspectHozizontal = true
            } else {
                frame.size.height = originFrame.height + yDelta
                frame.origin.x = originFrame.origin.x + xDelta
                frame.size.width = originFrame.width - xDelta
            }
            
            clampMinFromLeft = true
        case .bottomRight:
            if isAspectRatioLockEnabled {
                let distance = CGPoint(x: 1.0 - (-xDelta / originFrame.width), y: 1.0 - (-yDelta / originFrame.height))
                
                let scale = (distance.x + distance.y) * 0.5
                
                frame.size.width = ceil(originFrame.width * scale)
                frame.size.height = ceil(originFrame.height * scale)
                
                aspectHozizontal = true
                aspectVertical = true
            } else {
                frame.size.height = originFrame.height + yDelta
                frame.size.width = originFrame.width + xDelta
            }
        case .none:
            break
        }

        //The absolute max/min size the box may be in the bounds of the crop view
        var minSize = CGSize(width: minimumBoxSize, height: minimumBoxSize)
        var maxSize = CGSize(width: contentFrame.width, height: contentFrame.height)
        
        //clamp the box to ensure it doesn't go beyond the bounds we've set
        if isAspectRatioLockEnabled && aspectHozizontal {
            maxSize.height = contentFrame.width / aspectRatio
            minSize.width = minimumBoxSize * aspectRatio
        }
        
        if isAspectRatioLockEnabled && aspectVertical {
            maxSize.width = contentFrame.height * aspectRatio
            minSize.height = minimumBoxSize / aspectRatio
        }
        
        //Clamp the minimum size
        frame.size.width  = max(frame.width, minSize.width)
        frame.size.height = max(frame.height, minSize.height)
        
        //Clamp the maximum size
        frame.size.width  = min(frame.width, maxSize.width)
        frame.size.height = min(frame.height, maxSize.height)
        
        //Clamp the X position of the box to the interior of the cropping bounds
        frame.origin.x = max(frame.origin.x, contentFrame.minX)
        frame.origin.x = min(frame.origin.x, contentFrame.maxX - minSize.width)
        
        //Clamp the Y postion of the box to the interior of the cropping bounds
        frame.origin.y = max(frame.origin.y, contentFrame.minY)
        frame.origin.y = min(frame.origin.y, contentFrame.maxY - minSize.height)
        
        //Once the box is completely shrunk, clamp its ability to move
        if clampMinFromLeft && frame.width <= minSize.width + CGFloat.ulpOfOne {
            frame.origin.x = originFrame.maxX - minSize.width
        }
        
        //Once the box is completely shrunk, clamp its ability to move
        if clampMinFromTop && frame.height <= minSize.height + CGFloat.ulpOfOne {
            frame.origin.y = originFrame.maxY - minSize.height
        }
        
        setCropBoxFrame(frame)
        
        checkForCanReset()
    }
    
    private func cropEdge(forPoint point: CGPoint) -> CropViewOverlayEdge {
        var frame = _cropBoxFrame
        
        //account for padding around the box
        frame = frame.insetBy(dx: -32.0, dy: -32.0)
        
        //Make sure the corners take priority
        let topLeftRect = CGRect(origin: frame.origin, size: CGSize(width: 64.0, height: 64.0))
        if topLeftRect.contains(point) {
            return .topLeft
        }
        
        var topRightRect = topLeftRect
        topRightRect.origin.x = frame.maxX - 64.0
        if topRightRect.contains(point) {
            return .topRight
        }
        
        var bottomLeftRect = topLeftRect
        bottomLeftRect.origin.y = frame.maxY - 64.0
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }
        
        var bottomRightRect = topRightRect
        bottomRightRect.origin.y = bottomLeftRect.origin.y
        if bottomRightRect.contains(point) {
            return .bottomRight
        }
        
        //Check for edges
        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: 64.0))
        if topRect.contains(point) {
            return .top
        }
        
        var bottomRect = topRect
        bottomRect.origin.y = frame.maxY - 64.0
        if bottomRect.contains(point) {
            return .bottom
        }
        
        let leftRect = CGRect(origin: frame.origin, size: CGSize(width: 64.0, height: frame.height))
        if leftRect.contains(point) {
            return .left
        }
        
        var rightRect = leftRect
        rightRect.origin.x = frame.maxX - 64.0
        if rightRect.contains(point) {
            return .right
        }
        
        return .none
    }
    
    private func updateTo(imageCropFrame: CGRect) {
        
        //Convert the image crop frame's size from image space to the screen space
        let minimumSize = self.scrollView.minimumZoomScale
        let scaledOffset = CGPoint(x: imageCropFrame.origin.x * minimumSize, y: imageCropFrame.origin.y * minimumSize)
        let scaledCropSize = CGSize(width: imageCropFrame.size.width * minimumSize, height: imageCropFrame.size.height * minimumSize)
        
        // Work out the scale necessary to upscale the crop size to fit the content bounds of the crop bound
        let bounds = self.contentBounds
        let scale = min(bounds.size.width / scaledCropSize.width, bounds.size.height / scaledCropSize.height)
        
        // Zoom into the scroll view to the appropriate size
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale * scale
        
        // Work out the size and offset of the upscaed crop box
        var frame = CGRect.zero
        frame.size = CGSize(width: scaledCropSize.width * scale, height: scaledCropSize.height * scale)
        
        //set the crop box
        var cropBoxFrame = CGRect.zero
        cropBoxFrame.size = frame.size;
        cropBoxFrame.origin.x = (self.bounds.size.width - frame.size.width) * 0.5
        cropBoxFrame.origin.y = (self.bounds.size.height - frame.size.height) * 0.5
        self.setCropBoxFrame(cropBoxFrame)
        
        frame.origin.x = (scaledOffset.x * scale) - self.scrollView.contentInset.left
        frame.origin.y = (scaledOffset.y * scale) - self.scrollView.contentInset.top
        self.scrollView.contentOffset = frame.origin
    }
    
    // MARK: Timer
    
    private func startResetTimer() {
        guard resetTimer == nil else {
            return
        }
        
        resetTimer = Timer.scheduledTimer(timeInterval: cropTimerDuration, target: self, selector: #selector(timerTriggered), userInfo: nil, repeats: false)
    }
    
    @objc
    private func timerTriggered() {
        setEditing(false, animated: true)
        resetTimer?.invalidate()
        resetTimer = nil
    }
    
    private func cancelResetTimer() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
    
    func transform(with transformer: ImageTransformer) {
        
        let filteredImage = image?.hi.apply(transformer)
        foregroundImageView.image = filteredImage
        backgroundImageView.image = filteredImage
    }
    
    /**
     When performing large size transitions (eg, orientation rotation),
     set simple mode to YES to temporarily graphically heavy effects like translucency.
     
     @param simpleMode Whether simple mode is enabled or not
     
     */
    func setSimpleRenderMode(_ simpleMode: Bool, animated: Bool) {
        guard simpleMode != isSimpleRenderMode else {
            return
        }
        
        isSimpleRenderMode = simpleMode
        
        self.isEditing = false
        
        if animated {
            DispatchQueue.main.async {
                self.toggleTranslucencyViewVisible(!simpleMode)
            }
            return
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.toggleTranslucencyViewVisible(!simpleMode)
            }
        }
    }
    
    /**
     When performing a screen rotation that will change the size of the scroll view, this takes
     a snapshot of all of the scroll view data before it gets manipulated by iOS.
     Please call this in your view controller, before the rotation animation block is committed.
     */
    func prepareForRotation() {
        rotationContentOffset = scrollView.contentOffset
        rotationContentSize = scrollView.contentSize
        rotationBoundSize = scrollView.bounds.size
    }
    
    /**
     Performs the realignment of the crop view while the screen is rotating.
     Please call this inside your view controller's screen rotation animation block.
     */
    func performRelayoutForRotation() {
        
        var cropFrame = _cropBoxFrame
        let contentFrame = contentBounds
        
        let scale = min(contentFrame.size.width / cropFrame.size.width, contentFrame.size.height / cropFrame.size.height)
        scrollView.minimumZoomScale *= scale
        scrollView.zoomScale *= scale
        
        //Work out the centered, upscaled version of the crop rectangle
        cropFrame.size.width = (cropFrame.size.width * scale).rounded(.up)
        cropFrame.size.height = (cropFrame.size.height * scale).rounded(.up)
        cropFrame.origin.x = (contentFrame.origin.x + ((contentFrame.size.width - cropFrame.size.width) * 0.5)).rounded(.up)
        cropFrame.origin.y = (contentFrame.origin.y + ((contentFrame.size.height - cropFrame.size.height) * 0.5)).rounded(.up)
        setCropBoxFrame(cropFrame)
        
        captureStateForImageRotation()
        
        //Work out the center point of the content before we rotated
        let oldMidPoint = CGPoint(x: rotationBoundSize.width * 0.5, y: rotationBoundSize.height * 0.5)
        let contentCenter = CGPoint(x: rotationContentOffset.x + oldMidPoint.x, y: rotationContentOffset.y + oldMidPoint.y)
        
        //Normalize it to a percentage we can apply to different sizes
        var normalizedCenter = CGPoint.zero
        normalizedCenter.x = contentCenter.x / rotationContentSize.width
        normalizedCenter.y = contentCenter.y / rotationContentSize.height
        
        //Work out the new content offset by applying the normalized values to the new layout
        let newMidPoint = CGPoint(x: scrollView.bounds.size.width * 0.5, y: scrollView.bounds.size.height * 0.5)
        
        var translatedContentOffset = CGPoint.zero
        translatedContentOffset.x = scrollView.contentSize.width * normalizedCenter.x
        translatedContentOffset.y = scrollView.contentSize.height * normalizedCenter.y
        
        var offset = CGPoint.zero
        offset.x = (translatedContentOffset.x - newMidPoint.x).rounded(.up)
        offset.y = (translatedContentOffset.y - newMidPoint.y).rounded(.up)
        
        //Make sure it doesn't overshoot the top left corner of the crop box
        offset.x = max(-scrollView.contentInset.left, offset.x)
        offset.y = max(-scrollView.contentInset.top, offset.y)
        
        //Nor undershoot the bottom right corner
        var maximumOffset = CGPoint.zero
        maximumOffset.x = (self.bounds.size.width - scrollView.contentInset.right) + scrollView.contentSize.width;
        maximumOffset.y = (self.bounds.size.height - scrollView.contentInset.bottom) + scrollView.contentSize.height;
        offset.x = min(offset.x, maximumOffset.x)
        offset.y = min(offset.y, maximumOffset.y)
        scrollView.contentOffset = offset
        
        //Line up the background instance of the image
        matchForegroundToBackground()
    }
    
    /**
     Reset the crop box and zoom scale back to the initial layout
     
     @param animated The reset is animated
     */
    func resetLayoutToDefault(animated: Bool = true) {
   
        // If resetting the crop view includes resetting the aspect ratio,
        // reset it to zero here. But set the ivar directly since there's no point
        // in performing the relayout calculations right before a reset.
        if hasAspectRatio && isResetAspectRatioEnabled {
            aspectRatio = CGSize.zero
        }
        
        if !animated || self.angle != 0 {
            self.angle = 0
            
            scrollView.zoomScale = 1.0
            
            let imageRect = CGRect(origin: .zero, size: self.image!.size)
            
            backgroundImageView.transform = .identity
            backgroundContainerView.transform = .identity
            backgroundImageView.frame = imageRect
            backgroundContainerView.frame = imageRect
            
            foregroundImageView.transform = .identity
            foregroundImageView.frame = imageRect
            
            layoutInitialImage()
            
            checkForCanReset()
            
            return
        }
        
        //If we were in the middle of a reset timer, cancel it as we'll
        //manually perform a restoration animation here
        if resetTimer != nil {
            cancelResetTimer()
            setEditing(false, animated: false)
        }
        
        setSimpleRenderMode(true, animated: false)
        
        //Perform an animation of the image zooming back out to its original size
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(Int(0.01))) {
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: { 
                self.layoutInitialImage()
            }, completion: { (finished) in
                self.setSimpleRenderMode(false, animated: true)
            })
        }
    }
    
    /**
     Changes the aspect ratio of the crop box to match the one specified
     
     @param aspectRatio The aspect ratio (For example 16:9 is 16.0f/9.0f). 'CGSizeZero' will reset it to the image's own ratio
     @param animated Whether the locking effect is animated
     */
    func setAspectRatio(_ ratio: CGSize, animated: Bool = false) {
        self.aspectRatio = ratio
        
        // Will be executed automatically when added to a super view
        if superview == nil {
            return
        }
        
        var aspectRatio = ratio
        // Passing in an empty size will revert back to the image aspect ratio
        if aspectRatio.width < CGFloat.ulpOfOne && aspectRatio.height < CGFloat.ulpOfOne {
            aspectRatio = CGSize(width: imageSize.width, height: imageSize.height)
        }
        
        let boundsFrame = self.contentBounds
        var cropBoxFrame = _cropBoxFrame
        var offset = self.scrollView.contentOffset
        
        var cropBoxIsPortrait = false
        if Int(ratio.width) == 1 && Int(ratio.height) == 1 {
            cropBoxIsPortrait = self.image!.size.width > self.image!.size.height
        } else {
            cropBoxIsPortrait = aspectRatio.width < aspectRatio.height
        }
        
        var zoomOut = false
        
        if cropBoxIsPortrait {
            let newWidth = floor(cropBoxFrame.height * (aspectRatio.width / aspectRatio.height))
            let delta = cropBoxFrame.width - newWidth
            cropBoxFrame.size.width = newWidth
            offset.x += (delta * 0.5)
            
            if delta < CGFloat.ulpOfOne {
                cropBoxFrame.origin.x = self.contentBounds.origin.x
            }
            
            
            let boundsWidth = boundsFrame.width
            if newWidth > boundsWidth {
                let scale = boundsWidth / newWidth
                cropBoxFrame.size.height *= scale
                cropBoxFrame.size.width = boundsWidth
                zoomOut = true
            }
        } else {
            let newHeight = floor(cropBoxFrame.width * (aspectRatio.height / aspectRatio.width))
            let delta = cropBoxFrame.height - newHeight
            cropBoxFrame.size.height = newHeight
            offset.y = (delta * 0.5)
            
            if delta < CGFloat.ulpOfOne {
                cropBoxFrame.origin.x = self.contentBounds.origin.y
            }
            
            let boundsHeight = boundsFrame.height
            if newHeight > boundsHeight {
                let scale = boundsHeight / newHeight
                cropBoxFrame.size.width *= scale
                cropBoxFrame.size.height = boundsHeight
                zoomOut = true
            }
        }
        
        self.cropBoxLastEditedSize = cropBoxFrame.size
        self.cropBoxLastEditedAngle = self.angle
        
        let translateAction = {
            self.scrollView.contentOffset = offset
            self.setCropBoxFrame(cropBoxFrame)
            if zoomOut {
                self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            }
            
            self.moveCroppedContentToCenter(animated: false)
            self.checkForCanReset()
        }
        
        if !animated {
            translateAction()
            return
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: .beginFromCurrentState, animations: translateAction, completion: nil)
        }
    }

    /**
     Rotates the entire canvas to a 90-degree angle
     
     @param animated Whether the transition is animated
     @param clockwise Whether the rotation is clockwise. Passing 'NO' means counterclockwise
     */
    func rotateImageNinetyDegrees(animated: Bool = true, clockwise: Bool = false) {
        
        //Only allow one rotation animation at a time
        guard !self.isRotateAnimationInProgress else {
            return
        }
        
        //Cancel any pending resizing timers
        if self.resetTimer != nil {
            cancelResetTimer()
            setEditing(false, animated: false)
            
            cropBoxLastEditedAngle = self.angle
            captureStateForImageRotation()
        }
        
        //Work out the new angle, and wrap around once we exceed 360s
        var newAngel = self.angle
        newAngel = clockwise ? newAngel + 90 : newAngel - 90
        if newAngel <= -360 || newAngel >= 360 {
            newAngel = 0
        }
        
        self.angle = newAngel
        
        //Convert the new angle to radians
        let angleInRadians: CGFloat
        switch newAngel {
        case 90: angleInRadians =  CGFloat.pi / 2
        case -90: angleInRadians = -CGFloat.pi / 2
        case 180: angleInRadians = CGFloat.pi
        case -180: angleInRadians = -CGFloat.pi
        case 270: angleInRadians = (CGFloat.pi * 3 / 2)
        case -270: angleInRadians = -(CGFloat.pi * 3 / 2)
        default: angleInRadians = 0.0
        }
        
        // Set up the transformation matrix for the rotation
        let rotation = CGAffineTransform(rotationAngle: angleInRadians)
        
        //Work out how much we'll need to scale everything to fit to the new rotation
        let contentBounds = self.contentBounds
        let cropBoxFrame = _cropBoxFrame
        let scale = min(contentBounds.width / cropBoxFrame.height, contentBounds.height / cropBoxFrame.width)
        
        //Work out which section of the image we're currently focusing at
        let cropMidPoint = CGPoint(x: cropBoxFrame.midX, y: cropBoxFrame.midY)
        var cropTargetPoint = CGPoint(x: cropMidPoint.x + self.scrollView.contentOffset.x, y: cropMidPoint.y + self.scrollView.contentOffset.y)
        
        //Work out the dimensions of the crop box when rotated
        var newCropFrame = CGRect.zero
        if (labs(self.angle) == labs(self.cropBoxLastEditedAngle) || (labs(-self.angle) == (labs(self.cropBoxLastEditedAngle) - 180) % 360)) {
            newCropFrame.size = self.cropBoxLastEditedSize
            
            self.scrollView.minimumZoomScale = self.cropBoxLastEditedMinZoomScale
            self.scrollView.zoomScale = self.cropBoxLastEditedZoomScale
        } else {
            newCropFrame.size = CGSize(width: (_cropBoxFrame.height * scale).rounded(.up), height: (_cropBoxFrame.width * scale).rounded(.up))
            
            //Re-adjust the scrolling dimensions of the scroll view to match the new size
            self.scrollView.minimumZoomScale *= scale
            self.scrollView.zoomScale *= scale
        }
        
        newCropFrame.origin.x = ((self.bounds.width - newCropFrame.width) * 0.5).rounded(.up)
        newCropFrame.origin.y = ((self.bounds.height - newCropFrame.height) * 0.5).rounded(.up)
        
        //If we're animated, generate a snapshot view that we'll animate in place of the real view
        var snapshotView: UIView? = nil
        if animated {
            snapshotView = foregroundContainerView.snapshotView(afterScreenUpdates: false)
            isRotateAnimationInProgress = true
        }
        
        //Rotate the background image view, inside its container view
        backgroundImageView.transform = rotation
        
        //Flip the width/height of the container view so it matches the rotated image view's size
        let containerSize = backgroundContainerView.frame.size
        backgroundContainerView.frame = CGRect(origin: .zero, size: CGSize(width: containerSize.height, height: containerSize.width))
        backgroundImageView.frame = CGRect(origin: .zero, size: backgroundImageView.frame.size)
        
        //Rotate the foreground image view to match
        foregroundContainerView.transform = .identity
        foregroundImageView.transform = rotation
        
        //Flip the content size of the scroll view to match the rotated bounds
        scrollView.contentSize = self.backgroundContainerView.frame.size
        
        //assign the new crop box frame and re-adjust the content to fill it
        setCropBoxFrame(newCropFrame)
        moveCroppedContentToCenter(animated: false)
        newCropFrame = _cropBoxFrame
        
        //work out how to line up out point of interest into the middle of the crop box
        cropTargetPoint.x *= scale
        cropTargetPoint.y *= scale
        
        //swap the target dimensions to match a 90 degree rotation (clockwise or counterclockwise)
        let swap = cropTargetPoint.x
        if clockwise {
            cropTargetPoint.x = self.scrollView.contentSize.width - cropTargetPoint.y
            cropTargetPoint.y = swap
        } else {
            cropTargetPoint.x = cropTargetPoint.y
            cropTargetPoint.y = self.scrollView.contentSize.height - swap
        }
        
        //reapply the translated scroll offset to the scroll view
        let midPoint = CGPoint(x: newCropFrame.midX, y: newCropFrame.midY)
        var offset = CGPoint.zero
        offset.x = (-midPoint.x + cropTargetPoint.x).rounded(.up)
        offset.y = (-midPoint.y + cropTargetPoint.y).rounded(.up)
        offset.x = max(-self.scrollView.contentInset.left, offset.x)
        offset.y = max(-self.scrollView.contentInset.top, offset.y)
        
        //if the scroll view's new scale is 1 and the new offset is equal to the old, will not trigger the delegate 'scrollViewDidScroll:'
        //so we should call the method manually to update the foregroundImageView's frame
        if offset.x == self.scrollView.contentOffset.x && offset.y == self.scrollView.contentOffset.y && scale == 1 {
            matchForegroundToBackground()
        }
        self.scrollView.contentOffset = offset
        
        //If we're animated, play an animation of the snapshot view rotating,
        //then fade it out over the live content
        if animated, let snapshotView = snapshotView {
            snapshotView.center = self.scrollView.center
            addSubview(snapshotView)
            
            backgroundContainerView.isHidden = true
            foregroundContainerView.isHidden = true
            translucencyView.isHidden = true
            gridOverlayView.isHidden = true
            
            UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.8, options: .beginFromCurrentState, animations: { 
                var transform = CGAffineTransform(rotationAngle: clockwise ? CGFloat.pi / 2 : -CGFloat.pi / 2)
                transform = transform.scaledBy(x: scale, y: scale)
                snapshotView.transform = transform
            }, completion: { (finished) in
                self.backgroundContainerView.isHidden = false
                self.foregroundContainerView.isHidden = false
                self.translucencyView.isHidden = false
                self.gridOverlayView.isHidden = false
                
                self.backgroundContainerView.alpha = 0.0
                self.gridOverlayView.alpha = 0.0
                
                self.translucencyView.alpha = 1.0
                
                UIView.animate(withDuration: 0.45, animations: { 
                    snapshotView.alpha = 0.0
                    self.backgroundContainerView.alpha = 1.0
                    self.gridOverlayView.alpha = 1.0
                }, completion: { (finished) in
                    self.isRotateAnimationInProgress = false
                    snapshotView.removeFromSuperview()
                })
            })
        }
        
        checkForCanReset()
    }
    
    /**
     Animate the grid overlay graphic to be visible
     */
    func setGridOverlayHidden(_ hidden: Bool, animated: Bool = false) {
        isGridOverlayHidden = hidden
        gridOverlayView.alpha = hidden ? 1.0 : 0.0
       
        if animated {
            UIView.animate(withDuration: 0.4) {
                self.gridOverlayView.alpha = hidden ? 0.0 : 1.0
            }
        } else {
            gridOverlayView.alpha = hidden ? 0.0 : 1.0
        }
    }
    
    /**
     Animate the cropping component views to become visible
     */
    func setCroppingViewsHidden(_ hidden: Bool, animated: Bool = false) {
        guard isCroppingViewsHidden != hidden else { return }
        
        isCroppingViewsHidden = hidden
        
        let alpha: CGFloat = hidden ? 0.0 : 1.0
        
        if animated {
            foregroundContainerView.alpha = alpha
            backgroundImageView.alpha = alpha
            
            UIView.animate(withDuration: 0.4, animations: { 
                self.toggleTranslucencyViewVisible(!hidden)
                self.gridOverlayView.alpha = alpha
            })
        }
    }
    
    /**
     Animate the background image view to become visible
     */
    func setBackgroundImageViewHidden(_ hidden: Bool, animated: Bool) {
        if !animated {
            backgroundImageView.isHidden = hidden
        } else {
            let beforeAlpha: CGFloat = hidden ? 1.0 : 0.0
            let toAlpha: CGFloat = hidden ? 0.0 : 1.0
            
            backgroundImageView.isHidden = false
            backgroundImageView.alpha = beforeAlpha
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.backgroundImageView.alpha = toAlpha
            }, completion: { (finished) in
                if hidden {
                    self.backgroundImageView.isHidden = true
                }
            })
        }
    }
    
    /**
     When triggered, the crop view will perform a relayout to ensure the crop box
     fills the entire crop view region
     */
    func moveCroppedContentToCenter(animated: Bool = true) {
   
        guard !isInternalLayoutDisabled else { return }
        
        let contentRect = self.contentBounds
        var cropFrame = _cropBoxFrame
        
        // Ensure we only proceed after the crop frame has been setup for the first time
        if cropFrame.width < CGFloat.ulpOfOne || cropFrame.height < CGFloat.ulpOfOne {
            return
        }
        
        //The scale we need to scale up the crop box to fit full screen
        let scale = min(contentRect.width / cropFrame.width, contentRect.height / cropFrame.height)
        
        let focusPoint = CGPoint(x: cropFrame.midX, y: cropFrame.midY)
        let midPoint = CGPoint(x: contentRect.midX, y: contentRect.midY)
        
        cropFrame.size.width = ceil(cropFrame.width * scale)
        cropFrame.size.height = ceil(cropFrame.height * scale)
        cropFrame.origin.x = contentRect.origin.x + ceil((contentRect.width - cropFrame.width) * 0.5)
        cropFrame.origin.y = contentRect.origin.y + ceil((contentRect.height - cropFrame.height) * 0.5)
        
        //Work out the point on the scroll content that the focusPoint is aiming at
        var contentTargetPoint = CGPoint.zero
        contentTargetPoint.x = ((focusPoint.x + self.scrollView.contentOffset.x) * scale)
        contentTargetPoint.y = ((focusPoint.y + self.scrollView.contentOffset.y) * scale)
        
        //Work out where the crop box is focusing, so we can re-align to center that point
        var offset = CGPoint.zero
        offset.x = -midPoint.x + contentTargetPoint.x
        offset.y = -midPoint.y + contentTargetPoint.y
        
        //clamp the content so it doesn't create any seams around the grid
        offset.x = max(-cropFrame.origin.x, offset.x)
        offset.y = max(-cropFrame.origin.y, offset.y)
        
        let translateAction = { [weak self] in
            
            guard let sSelf = self else { return }
            
            // Setting these scroll view properties will trigger
            // the foreground matching method via their delegates,
            // multiple times inside the same animation block, resulting
            // in glitchy animations.
            //
            // Disable matching for now, and explicitly update at the end.
            sSelf.isDisableForgroundMatching = true
            do {
                // Slight hack. This method needs to be called during `[UIViewController viewDidLayoutSubviews]`
                // in order for the crop view to resize itself during iPad split screen events.
                // On the first run, even though scale is exactly 1.0f, performing this multiplication introduces
                // a floating point noise that zooms the image in by about 5 pixels. This fixes that issue.
                if scale < 1.0 - CGFloat.ulpOfOne || scale > 1.0 + CGFloat.ulpOfOne {
                    sSelf.scrollView.zoomScale *= scale
                }
                
                offset.x = min(-cropFrame.maxX + sSelf.scrollView.contentSize.width, offset.x)
                offset.y = min(-cropFrame.maxY + sSelf.scrollView.contentSize.height, offset.y)
                sSelf.scrollView.contentOffset = offset
                
                sSelf.setCropBoxFrame(cropFrame)
            }
            sSelf.isDisableForgroundMatching = false
            
            //Explicitly update the matching at the end of the calculations
            sSelf.matchForegroundToBackground()
        }
        
        if !animated {
            translateAction()
            return
        }
        
        matchForegroundToBackground()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(Int(0.01))) {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: translateAction, completion: nil)
        }
    }

}

extension CropView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == gridPanGestureRecognizer else { return true }
        
        let point = gestureRecognizer.location(in: self)
        
        let frame = gridOverlayView.frame
        
        let innerFrame = frame.insetBy(dx: 22.0, dy: 22.0)
        let outerFrame = frame.insetBy(dx: -22.0, dy: -22.0)
        
        if innerFrame.contains(point) || !outerFrame.contains(point) {
            return false
        } else {
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gridPanGestureRecognizer.state != .changed
    }
}

extension CropView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundContainerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startEditing()
        canBeReset = true
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        startEditing()
        canBeReset = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startResetTimer()
        checkForCanReset()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        startResetTimer()
        checkForCanReset()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            cropBoxLastEditedZoomScale = scrollView.zoomScale
            cropBoxLastEditedMinZoomScale = scrollView.minimumZoomScale
        }
        matchForegroundToBackground()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startResetTimer()
        }
    }
}
