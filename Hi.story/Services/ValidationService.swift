//
//  ValidationService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 31/12/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit
import RxSwift
import RealmSwift

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

struct ValidationService {
    
    static func validate(username: String) -> Observable<ValidationResult> {
        if username.isEmpty {
            return .just(.empty)
        }
        
        // this obviously won't be
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        // this obviously won't be
        if let start = username.first, "0123456789".contains(String(start)) {
            return .just(.failed(message: "Username can not start with numbers"))
        }
        
        if username.count < 4 || username.count > 16 {
            return .just(.failed(message: "Username must more than 3 characters and less than 17 characters"))
        }
        
        let loadingValue = ValidationResult.validating
        
        return RealmService.available(username: username)
            .map { available in
                if available {
                    return .ok(message: "Username available")
                } else {
                    return .failed(message: "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
}


/// Realm errors.
public enum RealmError: Swift.Error {
    /// Unknown error occurred.
    case unknown
    /// InitializeFailed error.
    case initializeFailed(error: Swift.Error)
}

extension RealmError: CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error has occurred."
        case let .initializeFailed(error):
            return "Can't initialize realm: \(error)"
        }
    }
}

struct RealmService {
   
    static func available(username: String) -> Observable<Bool> {
        
        return Observable.create { (observer) -> Disposable in
            
            realmQueue.async {
              
                do {
                    let realm = try Realm()
                    
                    if realm.objects(User.self).filter("username = %@", username).count > 0 {
                        observer.onNext(false)
                        observer.onCompleted()
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                    
                } catch let error {
                    return observer.on(.error(RealmError.initializeFailed(error: error)))
                }
                
            }
            
            return Disposables.create()
        }
    }
}

