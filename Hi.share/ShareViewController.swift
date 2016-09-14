//
//  ShareViewController.swift
//  Hi.share
//
//  Created by bl4ckra1sond3tre on 6/18/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices.UTType
import Hikit
import Hiconfig

class ShareViewController: SLComposeServiceViewController {
    
    fileprivate enum StoryboardIdentifier: String {
        case TitleViewController
        case TagsViewController
    }
    
    fileprivate lazy var titleItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()
        item?.title = "Title"
        item?.value = Date().hi.yearMonthDay
        item?.tapHandler = { [weak self] in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.TitleViewController.rawValue) as? TitleViewController {
                vc.pickAction = { [weak self](title) in
                    DispatchQueue.async {
                        item?.value = title
                    }
                }
                self?.pushConfigurationViewController(vc)
            }
        }
        return item!
    }()
    
    fileprivate lazy var tagItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()
        item?.title = "Tag"
        item?.value = "Default"
        item?.tapHandler = { [weak self] in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.TagsViewController.rawValue) as? TagsViewController {
                vc.pickAction = { [weak self](tag) in
                    self?.popConfigurationViewController()
                    DispatchQueue.async {
                        item?.value = tag
                    }
                }
                self?.pushConfigurationViewController(vc)
            }
        }
        return item!
    }()
    
    fileprivate var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(hex: HiConfig.Color.tintColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func presentationAnimationDidFinish() {
        
        imagesFromExtensionContext(extensionContext!) { [weak self] images in
            self?.images = images
            
            print("images: \(self?.images)")
        }
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        return !(contentText ?? "").isEmpty
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
        let shareType: ShareType
        let body = contentText ?? ""
        let title = titleItem.value
        if let image = images.first {
            shareType = .image(title: title!, body: body, image: image)
        } else {
            shareType = .plainText(title: title!, body: body)
        }
        
        post(shareType: shareType) { [weak self](finished) in
            self?.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [titleItem, tagItem]
    }
    
    
    // MARK: - Private
    
    fileprivate enum ShareType {
        
        case plainText(title: String, body: String)
        case image(title: String, body: String, image: UIImage)
        
        var body: String {
            switch self {
            case .plainText(_, let body): return body
            case .image(_, let body, _): return body
            }
        }
        
        var title: String {
            switch self {
            case .plainText(let title, _): return title
            case .image(let title, _, _): return title
            }
        }
    }
    
    fileprivate func post(shareType: ShareType, completion: (_ finished: Bool) -> Void) {
        let content = shareType.body
        let title = shareType.title
        let imageURL = URL(string: "")!
        
    }

}

extension ShareViewController {
    
    fileprivate func imagesFromExtensionContext(_ extensionContext: NSExtensionContext, completion: @escaping (_ images: [UIImage]) -> Void) {
        
        var images: [UIImage] = []
        
        guard let extensionItems = extensionContext.inputItems as? [NSExtensionItem] else {
            return completion([])
        }
        
        let imageTypeIdentifier = kUTTypeImage as String
        
        let group = DispatchGroup()
        
        for extensionItem in extensionItems {
            for attachment in extensionItem.attachments as! [NSItemProvider] {
                if attachment.hasItemConformingToTypeIdentifier(imageTypeIdentifier) {
                    
                    group.enter()
                    
                    attachment.loadItem(forTypeIdentifier: imageTypeIdentifier, options: nil) { secureCoding, error in
                        
                        if let fileURL = secureCoding as? URL, let image = UIImage(contentsOfFile: fileURL.path) {
                            images.append(image)
                        }
                        
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(images)
        }
    }

}
