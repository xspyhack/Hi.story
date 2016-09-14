//
//  Networking.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

let baseURL = "http://historyapp.sinaapp.com/"

struct Networking: Authorizable {
    
    enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }
    
    static func sendAuthRequest<T: Serializable>(_ authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: (Result<T>) -> Void) {
        Networking(authRequest: authRequest).sendRequest(parameters: parameters) { (result: Result<T>) in
            completionHandler(result)
        }
    }
    
    static func sendAuthRequest<T: Serializable>(_ authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: (Result<[T]>) -> Void) {
        Networking(authRequest: authRequest).sendRequest(parameters: parameters) { (result: Result<[T]>) in
            completionHandler(result)
        }
    }
    
    static func sendAuthRequest(_ authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: (Result<Bool>) -> Void) {
        Networking(authRequest: authRequest).sendRequest(parameters: parameters) { (result: Result<Bool>) in
            completionHandler(result)
        }
    }
    
    func sendRequest<T: Serializable>(parameters: JSONDictionary? = nil, completionHandler: (Result<T>) -> Void) {
        Request.shareRequest.request(authRequest, parameters: parameters) { (_, _, responseJson, error) in
            
            guard let json = responseJson as? JSONDictionary, let value = T(json: json)
                else {
                    completionHandler(.Failure(error?.localizedDescription))
                    return
            }
            
            completionHandler(.Success(value))
        }
    }
    
    func sendRequest<T: Serializable>(parameters: JSONDictionary? = nil, completionHandler: (Result<[T]>) -> Void) {
        Request.shareRequest.request(authRequest) { (_, _, responseJson, error) in
            
            guard let json = responseJson as? [JSONDictionary] else {
                completionHandler(.Failure(error?.localizedDescription))
                return
            }
            
            let values = json.flatMap { T(json: $0) }
            completionHandler(.Success(values))
        }
    }
    
    func sendRequest(parameters: JSONDictionary? = nil, completionHandler: (Result<Bool>) -> Void) {
        Request.shareRequest.request(authRequest, parameters: parameters) { (_, response, responseJSON, error) in
            if response?.statusCode < 300 && response?.statusCode >= 200 {
                completionHandler(.Success(true))
            } else if response?.statusCode == 404 {
                completionHandler(.Success(false))
            } else {
                completionHandler(.Failure(error?.localizedDescription))
            }
        }
    }
    
    fileprivate let authRequest: NSMutableURLRequest
    
    fileprivate init(authRequest: NSMutableURLRequest) {
        self.authRequest = authRequest
    }
    
    init(URLString: String, method: Method) {
        let authRequest = Request.shareRequest.authRequest(URLString: URLString, method: .GET)
        self.init(authRequest: authRequest)
    }
    
    func authRequest(URLString: String, method: Method) -> Networking {
        let URL = Foundation.URL(string: URLString)!
        
        let mutableURLRequest = NSMutableURLRequest(url: URL)
        mutableURLRequest.httpMethod = method.rawValue
        if let token = token {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return Networking(authRequest: mutableURLRequest)
    }
}

extension Networking: Wrapable {
    
    func wrap(_ json: JSONDictionary) -> String? {
        guard let result = json["result"] as? String , result == "SUCCESS" else {
            return json["result"] as? String
        }
        return nil
    }
    
    func errorHandler(_ json: JSONDictionary) -> String {
        return ""
    }
}

protocol Wrapable {
    
    func wrap(_ json: JSONDictionary) -> String?
    
    func errorHandler(_ json: JSONDictionary) -> String
}
