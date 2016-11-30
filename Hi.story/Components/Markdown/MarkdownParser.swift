//
//  MarkdownParser.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 26/11/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

struct MarkdownParser {
    
    static func loadHtmlHeader() -> String {
        
        let start = "<html><head><style media=\"screen\" type=\"text/css\">\n"
        let end = "</style></head><body><div class=\"note\"><div id=\"static_content\">"
        
        let cssPath = "markdown-default.css" // "markdown-dark.css"
        
        let css = Bundle.main.url(forResource: cssPath, withExtension: nil).flatMap {
            try? String(contentsOf: $0, encoding: .utf8)
        }
        
        return start + css! + end
    }
    
    static func loadHTMLFooter() -> String {
        return "</div></div></body></html>"
    }
    
    static func renderedHTML(with markdownText: String) {
       
        
    }

}
