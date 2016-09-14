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
    
    fileprivate enum FileKey: UInt {
        case record
        case programsList
        case hadCachedProgramsList
        case audioPlayState
    }
    
    enum Folder {
        case document
        case caches
        case tmp
        case home
        
        var homeDirectory: NSString {
            return (NSHomeDirectory() as NSString)
        }
        
        var path: String {
            switch self {
            case .home:
                return homeDirectory as String
            case .tmp:
                return homeDirectory.appendingPathComponent("tmp")
            case .document:
                return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            case .caches:
                return homeDirectory.appendingPathComponent("Library/Caches")
            }
        }
        
    }
    
    static func hi_isExistFile(_ fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: fileName)
    }
    
    static func hi_path(for folderName: String) -> String {
        return (Folder.home.path as NSString).appendingPathComponent(folderName)
    }
    
    static func hi_path(for folder: Folder, fileName: String) -> String {
        return (folder.path as NSString).appendingPathComponent(fileName)
    }
    
    static var hi_documentsPath: String {
        return Folder.document.path
    }
    
    static func hi_cachesPath() -> String {
        return Folder.caches.path
    }
    
    static func hi_tmpFolderPath() -> String {
        return Folder.tmp.path
    }
}
