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
    
    private enum StoryboardIdentifier: String {
        case TitleViewController
        case TagsViewController
    }
    
    private lazy var titleItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()
        item.title = "Title"
        item.value = NSDate().xh_yearMonthDay
        item.tapHandler = { [weak self] in
            if let vc = self?.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIdentifier.TitleViewController.rawValue) as? TitleViewController {
                vc.pickAction = { [weak self](title) in
                    DispatchQueue.async {
                        item.value = title
                    }
                }
                self?.pushConfigurationViewController(vc)
            }
        }
        return item
    }()
    
    private lazy var tagItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()
        item.title = "Tag"
        item.value = "Default"
        item.tapHandler = { [weak self] in
            if let vc = self?.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIdentifier.TagsViewController.rawValue) as? TagsViewController {
                vc.pickAction = { [weak self](tag) in
                    self?.popConfigurationViewController()
                    DispatchQueue.async {
                        item.value = tag
                    }
                }
                self?.pushConfigurationViewController(vc)
            }
        }
        return item
    }()
    
    private var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(hex: HiConfig.Color.tintColor)
    }
    
    override func viewDidAppear(animated: Bool) {
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
            shareType = .Image(title: title, body: body, image: image)
        } else {
            shareType = .PlainText(title: title, body: body)
        }
        
        post(shareType: shareType) { [weak self](finished) in
            self?.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        }
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [titleItem, tagItem]
    }
    
    
    // MARK: - Private
    
    private enum ShareType {
        
        case PlainText(title: String, body: String)
        case Image(title: String, body: String, image: UIImage)
        
        var body: String {
            switch self {
            case .PlainText(_, let body): return body
            case .Image(_, let body, _): return body
            }
        }
        
        var title: String {
            switch self {
            case .PlainText(let title, _): return title
            case .Image(let title, _, _): return title
            }
        }
    }
    
    private func post(shareType shareType: ShareType, completion: (finished: Bool) -> Void) {
        let content = shareType.body
        let title = shareType.title
        let imageURL = NSURL(string: "")!
        
    }

}

extension ShareViewController {
    
    private func imagesFromExtensionContext(extensionContext: NSExtensionContext, completion: (images: [UIImage]) -> Void) {
        
        var images: [UIImage] = []
        
        guard let extensionItems = extensionContext.inputItems as? [NSExtensionItem] else {
            return completion(images: [])
        }
        
        let imageTypeIdentifier = kUTTypeImage as String
        
        let group = dispatch_group_create()
        
        for extensionItem in extensionItems {
            for attachment in extensionItem.attachments as! [NSItemProvider] {
                if attachment.hasItemConformingToTypeIdentifier(imageTypeIdentifier) {
                    
                    dispatch_group_enter(group)
                    
                    attachment.loadItemForTypeIdentifier(imageTypeIdentifier, options: nil) { secureCoding, error in
                        
                        if let fileURL = secureCoding as? NSURL, image = UIImage(contentsOfFile: fileURL.path!) {
                            images.append(image)
                        }
                        
                        dispatch_group_leave(group)
                    }
                }
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(images: images)
        }
    }

}
