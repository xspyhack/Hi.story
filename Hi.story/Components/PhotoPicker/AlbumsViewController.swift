//
//  AlbumsViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Photos
import Hikit

struct Album {
    var asset: PHFetchResult<PHAsset>?
    var count = 0
    var name: String?
    var startDate: Date?
    var identifier: String?
}

private let defaultAlbumIdentifier = "com.xspyhack.History.photoPicker"

final class AlbumCell: UITableViewCell, Reusable {
    
    lazy var countLabel: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 12.0)
        return lable
    }()
    
    lazy var titleLabel: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 14.0)
        return lable
    }()
    
    lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    private func setup() {
        
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(countLabel)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "posterImageView": posterImageView,
            "titleLabel": titleLabel,
            "countLabel": countLabel,
        ]
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[posterImageView]-16-[titleLabel]-|", options: [], metrics: nil, views: views)
        let posterImageViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[posterImageView]-|", options: [], metrics: nil, views: views)
        
        let titleLabelCenterY = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -4.0)
        let countLabelCenterY = NSLayoutConstraint(item: countLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 4.0)
        let countLabelLeading = NSLayoutConstraint(item: countLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: 0.0)
        
        let posterImageViewRatio = NSLayoutConstraint(item: posterImageView, attribute: .width, relatedBy: .equal, toItem: posterImageView, attribute: .height, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate(h)
        NSLayoutConstraint.activate(posterImageViewV)
        NSLayoutConstraint.activate([titleLabelCenterY, countLabelCenterY, countLabelLeading, posterImageViewRatio])
    }
}

final class AlbumsViewController: UITableViewController {
   
    weak var delegate: PhotoPickerViewControllerDelegate?

    var contentInset: UIEdgeInsets = .zero {
        didSet {
            tableView.contentInset.bottom = contentInset.bottom
        }
    }
    
    var assetsCollection: [Album]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AlbumsViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.hidesBackButton = true
        
        tableView.hi.register(reusableCell: AlbumCell.self)
        
        tableView.tableFooterView = UIView()
        
        assetsCollection = fetchAlbumList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc fileprivate func cancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func fetchAlbumIdentifier() -> String? {
        let string = UserDefaults.standard.object(forKey: defaultAlbumIdentifier) as? String
        return string
    }
    
    fileprivate func fetchAlbum() -> Album? {

        let identifier = fetchAlbumIdentifier()
        
        guard identifier != nil else {
            return nil
        }
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        if result.count <= 0 {
            return nil
        }
        
        guard let collection = result.firstObject else {
            return nil
        }
        
        let asset = PHAsset.fetchAssets(in: collection, options: options)
        
        return Album(asset: asset, count: asset.count, name: collection.localizedTitle, startDate: collection.startDate, identifier: collection.localIdentifier)
    }
    
    fileprivate func fetchAlbumList() -> [Album] {
        
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        
        var results: [PHFetchResult<PHAssetCollection>] = []
        results.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil))
        results.append(PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: userAlbumsOptions))
        
        var list: [Album] = []
        guard !results.isEmpty else {
            return list
        }
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        results.forEach { result in
            
            result.enumerateObjects({ (collection: PHAssetCollection, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let album = collection
                guard  album.localizedTitle !=  NSLocalizedString("Recently Deleted", comment: "") else {
                    return
                }
                
                let asset = PHAsset.fetchAssets(in: album, options: options)
                
                let count: Int
                switch album.assetCollectionType {
                case .album:
                    count = asset.count
                case .smartAlbum:
                    count = asset.count
                case .moment:
                    count = 0
                }
                
                if count > 0 {
                    list.append(Album(asset: asset, count: asset.count, name: collection.localizedTitle, startDate: collection.startDate, identifier: collection.localIdentifier))
                }
            })
        }
        
        return list
    }
    
    fileprivate func fetchImageWithAsset(_ asset: PHAsset?, targetSize: CGSize, imageResultHandler: @escaping (_ image: UIImage?)->Void) -> PHImageRequestID? {
        guard let asset = asset else {
            return nil
        }
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        
        let scale = UIScreen.main.scale
        
        let size = CGSize(width: targetSize.width * scale, height: targetSize.height * scale);
        
        return PHCachingImageManager.default().requestImage(for: asset,targetSize: size, contentMode: .aspectFill, options: options) { (result, info) in
            imageResultHandler(result)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return assetsCollection == nil ? 0 : assetsCollection!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: AlbumCell = tableView.hi.dequeueReusableCell(for: indexPath)
        
        if let album = assetsCollection?[indexPath.row] {
            cell.countLabel.text = "(\(album.count))"
            cell.titleLabel.text = album.name
            
            SafeDispatch.async(onQueue: DispatchQueue.global(qos: .default)) { [weak self] in
                
                _ = self?.fetchImageWithAsset(album.asset?.lastObject, targetSize: CGSize(width: 60, height: 60), imageResultHandler: { (image) in
                    
                    SafeDispatch.async {
                        cell.posterImageView.image = image
                    }
                })
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let album = assetsCollection?[indexPath.row] else { return }
        
        let photoPicker = PhotoPickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        photoPicker.imagesDidFetch = true
        photoPicker.images = album.asset
        photoPicker.contentInset = contentInset
        photoPicker.delegate = delegate
        photoPicker.title = album.name
        
        print("before push")
        navigationController?.pushViewController(photoPicker, animated: true)
    }
}

