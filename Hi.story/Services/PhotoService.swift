//
//  PhotoService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/01/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import Photos

fileprivate let defaultAlbumIdentifier = "com.xspyhack.History.photoPicker"

struct Album {
    var asset: PHFetchResult<PHAsset>?
    var count = 0
    var name: String?
    var startDate: Date?
    var identifier: String?
}

struct Photo: Timetable {
    let createdAt: TimeInterval
    let asset: PHAsset
    let ratio: CGFloat // width / height
    let location: CLLocation?
}

func fetchMoments(at date: Date = Date()) -> [Photo] {
    
    var photos: [Photo] = []

    let momentOptions = PHFetchOptions()
    momentOptions.includeHiddenAssets = true
    momentOptions.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
    
    let moments = PHAssetCollection.fetchMoments(with: momentOptions)

    moments.enumerateObjects({ (moment, index, stop) in
        
        if moment.endDate?.hi.monthDay == date.hi.monthDay {
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            let assets = PHAsset.fetchAssets(in: moment, options: options)
           
            assets.enumerateObjects({ (asset, index, stop) in
                if let createdAt = asset.creationDate?.timeIntervalSince1970 {
                    photos.append(Photo(createdAt: createdAt, asset: asset, ratio: CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight), location: asset.location))
                }
            })
        }
    })
    
    return photos
}

func fetchURL(of asset: PHAsset, completionHandler: @escaping (URL?) -> Void) {
    
    if asset.mediaType == .image {
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isSynchronous = true
        
        PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { _, _, _, info in
            if let url = info?["PHImageFileURLKey"] as? URL {
                completionHandler(url)
            }
        })
        
        /*
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { _ in true }
        
        asset.requestContentEditingInput(with: options, completionHandler: { (input, info) in
            completionHandler(input?.fullSizeImageURL)
        })*/
        
    } else if asset.mediaType == .video {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { (av, audio, info) in
            
            if let urlAsset = av as? AVURLAsset {
                completionHandler(urlAsset.url)
            } else {
                completionHandler(nil)
            }
        })
    }
}

func fetchAlbumIdentifier() -> String? {
    let string = UserDefaults.standard.object(forKey: defaultAlbumIdentifier) as? String
    return string
}

func fetchAlbum() -> Album? {
    
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

func fetchAlbumList() -> [Album] {
    
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
            guard  album.localizedTitle != NSLocalizedString("Recently Deleted", comment: "") else {
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

@discardableResult
func fetchImage(with asset: PHAsset?, targetSize: CGSize, imageResultHandler: @escaping (_ image: UIImage?) -> Void) -> PHImageRequestID? {
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
