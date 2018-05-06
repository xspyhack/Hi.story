//
//  FeedViewModel.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 24/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

protocol FeedViewModelType {
    
    var feed: Feed { get }
    
    func toHTML() -> String
}

struct FeedViewModel: FeedViewModelType {
    
    let feed: Feed
    
    func toHTML() -> String {
        
        guard let story = feed.story else {
            return ""
        }
        
        let html: String
        
        var markdown = Markdown()
        let storyContent = sanitize(markdown.transform(story.body))
        
        if let attachment = story.attachment {
            let url = attachment.urlString.replacingOccurrences(of: "https", with: "hybrid")
            html = header(withTitle: story.title) + "<body><div><img src=\"\(url)\" /></div><article></h1><p>\(storyContent)</p></article>" + dateContent(with: story.createdAt) + footer
        } else {
            html = header(withTitle: story.title) + "<body><article><p>\(storyContent)</p></article>" + dateContent(with: story.createdAt) + footer
        }
        
        return html
    }
    
    // sanitize html fix xss attack
    private func sanitize(_ html: String) -> String {
        var string = html.replacingOccurrences(of: "<script>", with: "&lt;script&gt;")
        string = string.replacingOccurrences(of: "</script>", with: "&lt;/script&gt;")
        return string
    }
    
    private func header(withTitle title: String, forTheme theme: String = "k") -> String {
        let begin = "<html><head><title>" + sanitize(title) + "</title><meta charset='utf-8'><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"><style>"
        
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
