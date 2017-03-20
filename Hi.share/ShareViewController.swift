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
import RealmSwift

class ShareViewController: SLComposeServiceViewController {
    
    private enum StoryboardIdentifier: String {
        case titleViewController = "TitleViewController"
        case storybooksViewController = "StorybooksViewController"
    }
    
    private lazy var titleItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()
        item?.title = "Title"
        item?.value = Configuration.Defaults.storyTitle
        item?.tapHandler = { [weak self] in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.titleViewController.rawValue) as? TitleViewController {
                vc.pickAction = { [weak self] (title) in
                    DispatchQueue.main.async {
                        item?.value = title
                    }
                }
                self?.pushConfigurationViewController(vc)
            }
        }
        return item!
    }()
    
    private lazy var storybookItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()
        item?.title = "Storybook"
        item?.value = Configuration.Defaults.storybookName
        item?.tapHandler = { [weak self] in
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.storybooksViewController.rawValue) as? StorybooksViewController {
                vc.choosedAction = { [weak self] (storybook) in
                    self?.popConfigurationViewController()
                    DispatchQueue.main.async {
                        item?.value = storybook
                    }
                }
                self?.pushConfigurationViewController(vc)
            }
        }
        return item!
    }()
    
    private var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Realm.Configuration.defaultConfiguration = realmConfig()
        
        view.tintColor = UIColor.hi.tint
    }
    
    override func presentationAnimationDidFinish() {
        
        images(from: extensionContext!) { [weak self] images in
            self?.images = images
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
        let storybook = storybookItem.value
        
        if let image = images.first {
            shareType = .image(title: title!, body: body, image: image, storybook: storybook!)
        } else {
            shareType = .plainText(title: title!, body: body, storybook: storybook!)
        }
        
        post(shareType: shareType) { [weak self] (finished) in
            self?.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [titleItem, storybookItem]
    }
    
    
    // MARK: - Private
    
    fileprivate enum ShareType {
        
        case plainText(title: String, body: String, storybook: String)
        case image(title: String, body: String, image: UIImage, storybook: String)
        
        var body: String {
            switch self {
            case .plainText(_, let body, _): return body
            case .image(_, let body, _, _): return body
            }
        }
        
        var title: String {
            switch self {
            case .plainText(let title, _, _): return title
            case .image(let title, _, _, _): return title
            }
        }
        
        var storybook: String {
            switch self {
            case .image(_, _, _, let book): return book
            case .plainText(_, _, let book): return book
            }
        }
        
        var image: UIImage? {
            switch self {
            case .plainText: return nil
            case .image(_, _, let image, _): return image
            }
        }
    }
    
    private func post(shareType: ShareType, completion: (_ finished: Bool) -> Void) {
        
        guard let realm = try? Realm() else {
            completion(false)
            return
        }
        
        let story = Story()
        
        story.body = shareType.body
        story.title = shareType.title
        
        if let storybook = realm.objects(Storybook.self).filter("name = %@", shareType.storybook).first {
            story.withStorybook = storybook
        }
        
        if let image = shareType.image {
            let attement = Attachment()
            let meta = Meta()
            meta.widht = Double(image.size.width)
            meta.height = Double(image.size.height)
            attement.meta = meta
            attement.metadata = metadataString(of: image)
            story.attachment = attement
        }
        
        story.isPublished = true
        
        let feed = Feed()
        feed.story = story
        
        let creator = User.current
        feed.creator = creator
        
        feed.visible = 1
        
        FeedService.shared.synchronize(feed, toRealm: realm)
    }
}

extension ShareViewController {
    
    fileprivate func images(from extensionContext: NSExtensionContext, completion: @escaping (_ images: [UIImage]) -> Void) {
        
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
