//
//  StoryViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 11/04/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

protocol StoryViewModelType {
    
    var story: Story { get }
    
    var displayContents: String { get }
}

struct StoryViewModel: StoryViewModelType {
    
    let story: Story
    private(set) var displayContents: String
    
    init(story: Story) {
        
        self.story = story
        
        self.displayContents = ""
        
        var markdown = Markdown()
        let outputHtml: String = markdown.transform(story.body)
        
        if let attachment = story.attachment, let imageData = ImageCache.shared.retrieve(forKey: attachment.urlString) {
            
            let base64 = UIImageJPEGRepresentation(imageData, 1.0)?.base64EncodedString(options: .lineLength64Characters)
            
            let metadata = "data:image/png;base64,\(base64!)"
            self.displayContents = self.header() + "<body><div><img src=\"\(metadata)\" /></div><article></h1><p>\(outputHtml)</p></article>" + dateContent(with: story.createdAt) + footer
        } else {
            self.displayContents = self.header() + "<body><article><p>\(outputHtml)</p></article>" + dateContent(with: story.createdAt) + footer
        }
    }
    
    private func header(forTheme theme: String = "k") -> String {
        let begin = "<html><head><title></title><meta charset='utf-8'><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"><style>"
        
        let end = "</style></head>"
        
        return begin + (styles(forTheme: theme) ?? "") + end
    }
    
    private var footer: String {
        return "</body></html>"
    }
    
    private func dateContent(with interval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: interval).hi.monthDayYear
        return "<div style=\"text-align:center;height:120px;margin-top:80px;color:#a8a8a8;font-size:12px\">\(date)</div>"
    }
    
    private func styles(forTheme theme: String) -> String? {
        if let url = Bundle.main.path(forResource: theme, ofType: "css").flatMap({ URL(fileURLWithPath: $0) }), let contents = try? String(contentsOf: url, encoding: .utf8) {
            return contents
        } else {
            return nil
        }
    }
}
