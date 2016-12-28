//
//  CropToolbar.swift
//  Cropper
//
//  Created by bl4ckra1sond3tre on 07/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

protocol Namable {

    var named: String { get }
}

enum Filter: String {
    case none
    case mono
    case tonal
    case noir
    case fade
    case chrome
    case process
    case transfer
    case instant
    
    var ciFilter: CIFilter? {
        return CIFilter(name: "CIPhotoEffect" + rawValue.capitalized)
    }
    
    static var all: [Filter] {
        return [
            none,
            mono,
            tonal,
            noir,
            fade,
            chrome,
            process,
            transfer,
            instant,
        ]
    }
}

extension Filter: Namable {
    
    var named: String {
        return rawValue.capitalized
    }
}

extension Filter: ImageTransformer {
   
    var transform: (CIImage) -> CIImage? {
        
        return { image in
            
            guard let ciFilter = self.ciFilter else { return nil }
            
            ciFilter.setValue(image, forKey: kCIInputImageKey)
            
            let filteredImage = ciFilter.outputImage
            
            return filteredImage
        }
    }
}

struct Tint: ImageTransformer {
    let color: UIColor
    
    var transform: (CIImage) -> CIImage? {
        return { image in
            
            let colorFilter = CIFilter(name: "CIConstantColorGenerator")!
            colorFilter.setValue(CIColor(color: self.color), forKey: kCIInputColorKey)
            
            let colorImage = colorFilter.outputImage
            let filter = CIFilter(name: "CISourceOverCompositing")!
            filter.setValue(colorImage, forKey: kCIInputImageKey)
            filter.setValue(image, forKey: kCIInputBackgroundImageKey)
            return filter.outputImage?.cropping(to: image.extent)
        }
    }
}

final class PresetCell: UICollectionViewCell {
    
    enum SelectedStyle {
        case bordered
        case tinted
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.blue.cgColor
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    
    private var selectedStyle: SelectedStyle = .bordered
    
    private var image: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            switch selectedStyle {
            case .bordered:
                imageView.layer.borderWidth = isSelected ? 2.0 : 0.0
            case .tinted:
                imageView.image = isSelected ? image?.tinted(UIColor.blue) : image
            }
            textLabel.textColor = isSelected ? UIColor.blue : UIColor.gray
        }
    }
    
    private func setup() {
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "imageView": imageView,
            "textLabel": textLabel,
        ]
        
        let imageViewHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-4-[textLabel]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        let imageViewRatio = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(imageViewHConstraints)
        NSLayoutConstraint.activate(vConstraints)
        NSLayoutConstraint.activate([imageViewRatio])
    }
    
    func configure(with name: Namable, image: UIImage?, selectedStyle: SelectedStyle = .bordered) {
        textLabel.text = name.named
        imageView.image = image
        
        self.image = image
        self.selectedStyle = selectedStyle
    }
}

final class PhotoEditingToolbar: UIView {
    
    var image: UIImage?
    
    // tapped
    var doneButtonTapped: (() -> Void)?
    var cancelButtonTapped: (() -> Void)?
    var resetButtonTapped: (() -> Void)?
    
    var filterAction: ((Filter) -> Void)?
    
    var rotateButtonTapped: (() -> Void)?
    
    var ratioAction: ((AspectRatioPreset) -> Void)?
    
    // hidden
    var isRatioBarHidden = false {
        didSet {
            guard isRatioBarHidden != oldValue else { return }
            
            // todo
            setNeedsLayout()
        }
    }
    
    var isRotateButtonHidden: Bool = false {
        didSet {
            guard isRotateButtonHidden != oldValue else { return }
            
            // todo
            setNeedsLayout()
        }
    }
    
    var statusBarVisible: Bool = false
    
    var resetButtonEnabled: Bool = false {
        didSet {
            resetButton.isEnabled = resetButtonEnabled
        }
    }
    
    var isFilterButtonGlowing: Bool = false {
        didSet {
            guard isFilterButtonGlowing != oldValue else { return }
            
            filterButton.tintColor = isFilterButtonGlowing ? nil : UIColor.white
        }
    }
    
    var filterButtonFrame: CGRect {
        return filterButton.frame
    }
    
    var doneButtonFrame: CGRect {
        return doneButton.frame
    }
    
    /* In horizontal mode, offsets all of the buttons vertically by 20 points. */
    var isStatusBarVisible = true
    
    /* The 'Done' buttons to commit the crop. The text button is displayed
     in portrait mode and the icon one, in landscape. */
    private(set) lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /* The 'Cancel' buttons to cancel the crop. The text button is displayed
     in portrait mode and the icon one, in landscape. */
    private(set) lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /* The cropper control buttons */
    
    private(set) lazy var resetButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private(set) lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "filter"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    // rotateCounterclockwiseButton
    private(set) lazy var rotateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "rotate"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var ratioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ratio"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    static let toolbarHeight: CGFloat = 128.0
    
    struct Constant {
        static let presetSize = CGSize(width: 60.0, height: 80.0)
        static let presetGap: CGFloat = 4.0
    }
    
    fileprivate var ratioes: [AspectRatioPreset] = [
        .threetwo, .fourthree, .square, .threefour, .fourfive, .sixteennine
    ]
    
    fileprivate var filters: [Filter] = Filter.all
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Constant.presetGap
        flowLayout.minimumLineSpacing = Constant.presetGap
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(PresetCell.self, forCellWithReuseIdentifier: "PresetCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()

    private lazy var containerView: UIView = UIView()
    
    enum Preset {
        case filter
        case ratio
    }
    
    var preset: Preset = .ratio {
        didSet {
            guard preset != oldValue else { return }
            
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, rotateButton, ratioButton, filterButton, resetButton, doneButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        addSubview(stackView)
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "containerView": containerView,
            "stackView": stackView,
            "collectionView": collectionView,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]-4-[stackView(44)]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
        
        let collectionViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views)
        let collectionViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(collectionViewH)
        NSLayoutConstraint.activate(collectionViewV)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == self.cancelButton {
            cancelButtonTapped?()
        } else if sender == doneButton {
            doneButtonTapped?()
        } else if sender == resetButton {
            resetButtonTapped?()
        } else if sender == rotateButton {
            rotateButtonTapped?()
        } else if sender == ratioButton {
            preset = .ratio
        } else if sender == filterButton {
            preset = .filter
        }
    }
}

extension PhotoEditingToolbar: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return preset == .ratio ? ratioes.count : filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PresetCell", for: indexPath) as! PresetCell
        
        switch preset {
        case .filter:
            let filter = filters[indexPath.item]
            cell.configure(with: filter, image: image?.hi.apply(filter))
        case .ratio:
            let ratio = ratioes[indexPath.item]
            cell.configure(with: ratio, image: UIImage(named: "ratio_\(ratio.named)"), selectedStyle: .tinted)
        }
        
        return cell
    }
}

extension PhotoEditingToolbar: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch preset {
        case .filter:
            filterAction?(filters[indexPath.item])
        case .ratio:
            ratioAction?(ratioes[indexPath.item])
        }
    }
}

extension PhotoEditingToolbar: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        switch preset {
        case .filter:
            return Constant.presetSize
        case .ratio:
            return CGSize(width: (collectionView.bounds.width - CGFloat(ratioes.count - 1) * Constant.presetGap) / CGFloat(ratioes.count) , height: Constant.presetSize.height)
        }
    }
}
