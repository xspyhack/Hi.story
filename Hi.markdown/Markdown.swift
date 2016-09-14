//
//  Markdown.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import UIKit

indirect enum Markdown {
    case ita([Markdown])
    case bold([Markdown])
    case header(Int, [Markdown])
    case inlineCode([Markdown])
    case codeBlock(String)
    case links([Markdown], String)
    case plain(String)
    case refer([Markdown])
    case delete([Markdown])
}

public protocol MarkdownConfigurable {
    var fontName: UIFont { get set }
    var foregroundColor: UIColor? { get set }
    var backgroundColor: UIColor? { get set }
}

public protocol HeaderStyleConfigurable {
    var fontSize: ((Int) -> Int)? { get set }
}

public struct TrivialStyle: MarkdownConfigurable {
    public var fontName: UIFont
    public var foregroundColor: UIColor?
    public var backgroundColor: UIColor?
}

public struct HeaderStyle: MarkdownConfigurable, HeaderStyleConfigurable {
    public var fontName: UIFont
    public var foregroundColor: UIColor?
    public var backgroundColor: UIColor?
    public var fontSize: ((Int) -> Int)?
}

typealias MD = MarkdownParser

open class MarkdownParser {
    
    let reserved = "`*#[(~"
    
    open var boldStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.boldSystemFont(ofSize: 18), foregroundColor: nil, backgroundColor: nil)
    open var italicsStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.italicSystemFont(ofSize: 17), foregroundColor: nil, backgroundColor: nil)
    open var inlineCodeStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFont(ofSize: 17), foregroundColor: nil, backgroundColor: UIColor.hexColor(0xdddddd))
    
    open var linksStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFont(ofSize: 17), foregroundColor: UIColor.blue, backgroundColor: nil)
    
    open var plainTextStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFont(ofSize: 17), foregroundColor: nil, backgroundColor: nil)
    
    open var referTextStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFont(ofSize: 17), foregroundColor: nil, backgroundColor: UIColor.hexColor(0xeff5fe))
    
    
    open var codeBlockStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFont(ofSize: 17), foregroundColor: UIColor.white, backgroundColor: UIColor.quickRGB(r: 33, g: 37, b: 43))
    
    open var deleteStyle: MarkdownConfigurable =
        TrivialStyle(fontName: UIFont.systemFont(ofSize: 17), foregroundColor: nil, backgroundColor: nil)
    
    open var headerStyle: HeaderStyleConfigurable = HeaderStyle(fontName: UIFont.boldSystemFont(ofSize: 18), foregroundColor: nil, backgroundColor: nil) { (NthHeader) -> Int in
        return 28 + (6 - 2 * NthHeader)
    }
    
    public init(){
        
    }
    
    open func convert(_ string: String) -> NSAttributedString {
        let result = self.parserEntry().parse(string)
        if result.count <= 0 {
            return NSAttributedString(string: "Parsing failed")
        } else {
            return render(result[0].0)
        }
    }
    
    func markdown() -> Parser<Markdown> {
        return refer() +++ bold() +++ ita() +++ codeblock() +++ delete() +++ inlineCode() +++ header() +++ links() +++ plain()
            +++ newline() +++ fakeNewline() +++ reservedHandler()
    }
    
    
    func markdowns() -> Parser<[Markdown]> {
        let m = space(false) >>= { _ in self.markdown() }
        let mm = many1loop(m)
        return Parser { str in
            return mm.parse(str)
        }
    }
    
    func parserEntry() -> Parser<[Markdown]> {
        return (pureHeader() >>= { h in
            self.markdowns() >>= { mds in
                var tmds:[Markdown] = mds
                tmds.insert(h, at: 0)
                return pure(tmds)
            }
        }) +++ markdowns()
    }
}

extension MarkdownParser {
    
    fileprivate func reservedHandler() -> Parser<Markdown> {
        func pred(_ c : Character) -> Bool{
            return reserved.characters.index(of: c) != nil
        }
        
        return satisfy(pred) >>= { c in
            pure(.plain(String(c)))
        }
    }
    
    fileprivate func header() -> Parser<Markdown> {
        return many1loop(self.fakeNewline()) >>= { _ in
            self.pureHeader()
        }
    }
    
    fileprivate func pureHeader() -> Parser<Markdown>{
        return many1loop(parserChar("#")) >>= { cs in
            line() >>= { str in
                var tmds: [Markdown] = self.pureStringParse(str)
                tmds.insert(.plain("\n"), at: 0)
                tmds.append(.plain("\n"))
                return pure(.header(cs.count, tmds))
            }
        }
    }
    
    fileprivate func ita() -> Parser<Markdown> {
        return pair("*") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.ita(mds))
        }
    }
    
    fileprivate func delete() -> Parser<Markdown> {
        return pair("~~") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.delete(mds))
        }
    }
    
    fileprivate func bold() -> Parser<Markdown> {
        return pair("**") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.bold(mds))
        }
    }
    
    fileprivate func inlineCode() -> Parser<Markdown> {
        return pair("`") >>= { str in
            let mds = self.pureStringParse(str)
            return pure(.inlineCode(mds))
        }
    }
    
    fileprivate func links() -> Parser<Markdown> {
        return pair("[", sepa2: "]") >>= { str in
            pair("(", sepa2: ")") >>= { str1 in
                let mds = self.pureStringParse(str)
                return pure(.links(mds,str1))
                
            }
        }
    }
    
    fileprivate func markdownNewlineBreak() ->Parser<String> {
        let p = trimedSatisfy(isNewline)
        return p >>= { _ in
            many1loop(p) >>= { _ in
                pure("\n")
            }
        }
    }
    
    fileprivate func newline() -> Parser<Markdown> {
        return markdownNewlineBreak() >>= { str in
            pure(.plain(str))
        }
    }
    
    fileprivate func fakeNewline() -> Parser<Markdown> {
        return trimedSatisfy(isNewline) >>= { _ in
            pure(.plain(" "))
        }
    }
    
    fileprivate func markdownLineStr() ->Parser<String> {
        return Parser { str in
            var result = ""
            var rest = str
            
            while(true){
                var temp = lineStr().parse(rest)
                guard temp.count > 0 else {
                    result.append(rest[rest.startIndex])
                    rest = String(rest.characters.dropFirst())
                    continue
                }
                
                result += temp[0].0
                rest = temp[0].1
                
                if rest == "" {
                    break
                }
                
                let linebreaks = self.markdownNewlineBreak().parse(temp[0].1)
                if linebreaks.count > 0{
                    break
                }else{
                    continue
                }
            }
            
            return [(result, rest)]
        }
    }
    
    fileprivate func plain() -> Parser<Markdown> {
        func pred(_ c : Character) -> Bool{
            
            if reserved.characters.index(of: c) != nil{
                return false
            }
            return isNotNewline(c)
        }
        
        return many1loop(satisfy(pred)) >>= { cs in
            pure(.plain(String(cs)))
        }
    }
    
    fileprivate func pureStringParse(_ string : String) -> [Markdown] {
        let result = self.markdowns().parse(string)
        if result.count > 0 {
            return result[0].0
        }else{
            return []
        }
    }
    
    fileprivate func refer() -> Parser<Markdown> {
        return many1loop(self.fakeNewline()) >>= { _ in
            space(false) >>= { _ in
                symbol(">") >>= { _ in
                    self.markdownLineStr() >>= { str in
                        var mds:[Markdown] = self.pureStringParse(str)
                        //mds.insert(.Plain("\n"), atIndex: 0)
                        mds.append(.plain("\n"))
                        return pure(.refer(mds))
                    }
                }
            }
        }
    }
    
    fileprivate func codeblock() -> Parser<Markdown> {
        return symbol("```") >>= { _ in
            ((lineStr() >>= {_ in space(true)} ) +++ space(true)) >>= { _ in
                until("```") >>= { str in
                    symbol("```") >>= {_ in pure(.codeBlock(str))}
                }
            }
        }
    }
}

extension MarkdownParser {
    func render(_ arr: [Markdown]) -> NSAttributedString {
        return renderHelper(arr, parentAttribute: nil)
    }
    
    func renderHelper(_ arr: [Markdown], parentAttribute: [String: AnyObject]?) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString()
        
        for m in arr {
            var baseAttribute:[String: AnyObject] = [:]
            
            if let _ = parentAttribute {
                for att in parentAttribute! {
                    baseAttribute[att.0] = att.1
                }
            }
            
            switch m {
            case .bold(let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                if tAttr[NSFontAttributeName] != nil {
                    let font = tAttr[NSFontAttributeName]!.pointSize
                    tAttr[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: font!)
                    
                } else {
                    tAttr[NSFontAttributeName] = boldStyle.fontName
                }
                
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.append(subAttrString)
                
            case .ita(let mds):
                var tAttr:[String:AnyObject] = baseAttribute
                
                if tAttr[NSFontAttributeName]  != nil {
                    let font = tAttr[NSFontAttributeName]!.pointSize
                    tAttr[NSFontAttributeName] = UIFont.italicSystemFont(ofSize: font!)
                    
                } else {
                    tAttr[NSFontAttributeName] = italicsStyle.fontName
                }
                
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.append(subAttrString)
                
            case .header(let level, let mds):
                var tAttr: [String: AnyObject] = baseAttribute
                tAttr[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: CGFloat(headerStyle.fontSize!(level)))
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.append(subAttrString)
                
            case .inlineCode(let mds):
                
                var tAttr: [String:AnyObject] = baseAttribute
                
                tAttr[NSFontAttributeName] = inlineCodeStyle.fontName
                tAttr[NSBackgroundColorAttributeName] = inlineCodeStyle.backgroundColor
                tAttr[NSForegroundColorAttributeName] = inlineCodeStyle.foregroundColor
                
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                
                attributedString.append(subAttrString)
                
            case .links(let mds, let links):
                var tAttr:[String: AnyObject] = baseAttribute
                
                tAttr[NSLinkAttributeName] = links as AnyObject?
                tAttr[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
                tAttr[NSForegroundColorAttributeName] = linksStyle.foregroundColor
                tAttr[NSBackgroundColorAttributeName] = linksStyle.backgroundColor
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                
                attributedString.append(subAttrString)
                
            case .plain(let str):
                if baseAttribute[NSFontAttributeName] == nil{
                    baseAttribute[NSFontAttributeName] = plainTextStyle.fontName
                }
                
                attributedString.append(NSAttributedString(string: str, attributes: baseAttribute))
                
            case .refer(let mds):
                attributedString.append(NSAttributedString(string: "\n\n"))
                
                var tAttr:[String:AnyObject] = baseAttribute
                tAttr[NSBackgroundColorAttributeName] = referTextStyle.backgroundColor
                
                let paras = NSMutableParagraphStyle()
                paras.paragraphSpacing = 10
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.append(subAttrString)
                
            case .codeBlock(let code):
                attributedString.append(NSAttributedString(string: "\n"))
                let backgroundColor = codeBlockStyle.backgroundColor
                let foregroundColor = codeBlockStyle.foregroundColor
                let paras = NSMutableParagraphStyle()
                paras.paragraphSpacing = 0
                attributedString.append(NSAttributedString(string: code, attributes: [NSBackgroundColorAttributeName: backgroundColor!, NSForegroundColorAttributeName: foregroundColor!, NSParagraphStyleAttributeName: paras]))
                
            case .delete(let mds):
                var tAttr: [String: AnyObject] = baseAttribute
                if tAttr[NSFontAttributeName] == nil {
                    tAttr[NSFontAttributeName] = deleteStyle.fontName
                }
                tAttr[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleDouble.rawValue as AnyObject?
                let subAttrString = renderHelper(mds, parentAttribute: tAttr)
                attributedString.append(subAttrString)
            }
        }
        
        return attributedString
    }
}

extension UIColor {
    
    static func hexColor(_ value: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat((value & 0xFF0000) >> 16) / 255.0, green: CGFloat((value & 0xFF00) >> 8) / 255.0, blue: CGFloat(value & 0xFF) / 255.0, alpha: alpha)
    }
    
    static func quickRGB(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
