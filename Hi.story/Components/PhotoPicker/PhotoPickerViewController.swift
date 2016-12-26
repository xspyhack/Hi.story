//
//  PhotoPickerViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Hikit
import Photos

final class PhotoCell: UICollectionViewCell, Reusable {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
   
    var imageManager: PHImageManager?
    
    var imageAsset: PHAsset? {
        willSet {
            guard let imageAsset = newValue else {
                return
            }
            
            let options = PHImageRequestOptions.sharedOptions
            
            let width: CGFloat = 188.0
            let height = width
            let targetSize = CGSize(width: width, height: height)
            
            DispatchQueue.global(qos: .default).async { [weak self] in
                self?.imageManager?.requestImage(for: imageAsset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] image, info in
                    
                    SafeDispatch.async { [weak self] in
                        self?.imageView.image = image
                    }
                }
            }
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
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["imageView": imageView]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(v)
    }
}

protocol PhotoPickerViewControllerDelegate: class {
    
    func photoPickerControllerDidCancel(_ picker: PhotoPickerViewController)
    
    func photoPickerController(_ picker: PhotoPickerViewController, didFinishPickingPhoto photo: UIImage)
}

extension PhotoPickerViewControllerDelegate {
    
    func photoPickerControllerDidCancel(_ picker: PhotoPickerViewController) {
    }
    
    func photoPickerController(_ picker: PhotoPickerViewController, didFinishPickingPhoto photo: UIImage) {
    }
}

final class PhotoPickerViewController: UICollectionViewController, PHPhotoLibraryChangeObserver {
    
    var images: PHFetchResult<PHAsset>? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    weak var delegate: PhotoPickerViewControllerDelegate?
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            collectionView?.contentInset.bottom = contentInset.bottom
        }
    }

    var needsScrollToBottom: Bool = true
    var imagesDidFetch: Bool = false
    fileprivate let imageManager = PHCachingImageManager()
    private var imageCacheController: ImageCacheController?
    
    private var navigationDidConfigure = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = collectionView else { return }
        
        collectionView.contentInset.bottom = contentInset.bottom
        
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        automaticallyAdjustsScrollViewInsets = false
        
        collectionView.hi.register(reusableCell: PhotoCell.self)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let gap: CGFloat = 1.0
            
            let width: CGFloat = (view.bounds.width - 5 * gap)  / 4
            let height = width
            layout.itemSize = CGSize(width: width, height: height)
            
            layout.minimumInteritemSpacing = gap
            layout.minimumLineSpacing = gap
            layout.sectionInset = UIEdgeInsets(top: gap + 64, left: gap, bottom: gap, right: gap)
        }
        
        let backBarButtonItem = UIBarButtonItem(image: UIImage.hi.navBack, style: .plain, target: self, action: #selector(PhotoPickerViewController.back(_:)))
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PhotoPickerViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = cancelButton
      
        if !imagesDidFetch {
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            title = "All Photos"
            images = PHAsset.fetchAssets(with: .image, options: options)
            
        }
        PHPhotoLibrary.shared().register(self)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsScrollToBottom {
            scrollToBottom()
            needsScrollToBottom = false
        }
        
        if needsScrollToBottom {
            scrollToBottom()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        if !navigationDidConfigure {
            navigationDidConfigure = true
            
            guard var viewControllers = navigationController?.viewControllers else { return }
            
            let count = viewControllers.count
            if !(viewControllers[count - 1] is AlbumsViewController) {
                // previous is not albumsViewController
                let albumsViewController = AlbumsViewController()
                albumsViewController.contentInset = contentInset
                albumsViewController.delegate = delegate
                viewControllers.insert(albumsViewController, at: count - 1)
                navigationController?.setViewControllers(viewControllers, animated: false)
            }
            
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
        
        guard let images = images else { return }
        
        imageCacheController = ImageCacheController(imageManager: imageManager, images: images, preheatSize: 1)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: Actions
    
    @objc private func back(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancel(_ sender: UIBarButtonItem) {
        delegate?.photoPickerControllerDidCancel(self)
    }
    
    private func scrollToBottom() {
        guard let images = images, let collectionView = collectionView else { return }
        
        collectionView.scrollToItem(at: IndexPath(item: images.count - 1, section: 0), at: .centeredVertically, animated: false)
    }
    
    private func pick(_ imageAsset: PHAsset) {
        
        let options = PHImageRequestOptions.sharedOptions
        
        imageManager.requestImageData(for: imageAsset, options: options, resultHandler: { [weak self] (data, String, imageOrientation, _) -> Void in
            if let sSelf = self, let data = data, let image = UIImage(data: data) {
                self?.delegate?.photoPickerController(sSelf, didFinishPickingPhoto: image)
            }
        })
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoCell = collectionView.hi.dequeueReusableCell(for: indexPath)
        
        cell.imageManager = imageManager
        if let imageAsset = images?[indexPath.item] {
            cell.imageAsset = imageAsset
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let imageAsset = images?[indexPath.item] {
            pick(imageAsset)
        }
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changeDetails = changeInstance.changeDetails(for: images!) else {
            return
        }
        
        self.images = changeDetails.fetchResultAfterChanges
        
        SafeDispatch.async {
            // Loop through the visible cell indices
            guard let
                indexPaths = self.collectionView?.indexPathsForVisibleItems,
                let changedIndexes = changeDetails.changedIndexes else {
                    return
            }
            
            for indexPath in indexPaths {
                if changedIndexes.contains(indexPath.item) {
                    let cell = self.collectionView?.cellForItem(at: indexPath) as! PhotoCell
                    cell.imageAsset = changeDetails.fetchResultAfterChanges[indexPath.item]
                }
            }
        }
    }
}

extension PhotoPickerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return true
        }
        return false
    }
}

extension PHImageRequestOptions {
    
    static var sharedOptions: PHImageRequestOptions {
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        
        return options
    }
}

