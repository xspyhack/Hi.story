//
//  String+Path.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 8/18/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    private enum FileKey: UInt {
        case Record
        case ProgramsList
        case HadCachedProgramsList
        case AudioPlayState
    }
    
    enum Folder {
        case Document
        case Caches
        case Tmp
        case Home
        
        var homeDirectory: NSString {
            return (NSHomeDirectory() as NSString)
        }
        
        var path: String {
            switch self {
            case .Home:
                return homeDirectory as String
            case .Tmp:
                return homeDirectory.stringByAppendingPathComponent("tmp")
            case .Document:
                return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
            case .Caches:
                return homeDirectory.stringByAppendingPathComponent("Library/Caches")
            }
        }
        
    }
    
    static func hi_isExistFile(fileName: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(fileName)
    }
    
    static func hi_path(for folderName: String) -> String {
        return (Folder.Home.path as NSString).stringByAppendingPathComponent(folderName)
    }
    
    static func hi_path(for folder: Folder, fileName: String) -> String {
        return (folder.path as NSString).stringByAppendingPathComponent(fileName)
    }
    
    static var hi_documentsPath: String {
        return Folder.Document.path
    }
    
    static func hi_cachesPath() -> String {
        return Folder.Caches.path
    }
    
    static func hi_tmpFolderPath() -> String {
        return Folder.Tmp.path
    }
}
