//
//  Networking.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

/*
 
let baseURL = "http://historyapp.sinaapp.com/"

struct NetworkingError: Error {
    let code: Int
    
    static var `default`: NetworkingError {
        return NetworkingError(code: -1)
    }
}

struct Networking: Authorizable {
    
    enum Method: String {
        case options, get, head, post, put, patch, delete, trace, connect
        
        var value: String {
            return self.rawValue.uppercased()
        }
    }
    
    static func sendAuthRequest<T: Serializable>(_ authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: @escaping (Result<T>) -> Void) {
        Networking(authRequest: authRequest).sendRequest(parameters: parameters) { (result: Result<T>) in
            completionHandler(result)
        }
    }
    
    static func sendAuthRequest<T: Serializable>(_ authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: @escaping (Result<[T]>) -> Void) {
        Networking(authRequest: authRequest).sendRequest(parameters: parameters) { (result: Result<[T]>) in
            completionHandler(result)
        }
    }
    
    static func sendAuthRequest(_ authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: @escaping (Result<Bool>) -> Void) {
        Networking(authRequest: authRequest).sendRequest(parameters: parameters) { (result: Result<Bool>) in
            completionHandler(result)
        }
    }
    
    func sendRequest<T: Serializable>(parameters: JSONDictionary? = nil, completionHandler: @escaping (Result<T>) -> Void) {
        Request.shared.request(authRequest, parameters: parameters) { (_, _, responseJSON, error) in
            
            if let error = error {
                completionHandler(.failure(error))
            }
            
            guard let json = responseJSON as? JSONDictionary, let value = T(json: json)
                else {
                    completionHandler(.failure(NetworkingError.default))
                    return
            }
            
            completionHandler(.success(value))
        }
    }
    
    func sendRequest<T: Serializable>(parameters: JSONDictionary? = nil, completionHandler: @escaping (Result<[T]>) -> Void) {
        Request.shared.request(authRequest) { (_, _, responseJSON, error) in
            
            guard let json = responseJSON as? [JSONDictionary] else {
                completionHandler(.failure(error ?? NetworkingError.default))
                return
            }
            
            let values = json.flatMap { T(json: $0) }
            completionHandler(.success(values))
        }
    }
    
    func sendRequest(parameters: JSONDictionary? = nil, completionHandler: @escaping (Result<Bool>) -> Void) {
        Request.shared.request(authRequest, parameters: parameters) { (_, response, responseJSON, error) in
            if (response?.statusCode)! < 300 && (response?.statusCode)! >= 200 {
                completionHandler(.success(true))
            } else if response?.statusCode == 404 {
                completionHandler(.success(false))
            } else {
                completionHandler(.failure(error ?? NetworkingError.default))
            }
        }
    }
    
    private let authRequest: NSMutableURLRequest
    
    private init(authRequest: NSMutableURLRequest) {
        self.authRequest = authRequest
    }
    
    init(urlString: String, method: Method) {
        let authRequest = Request.shared.authRequest(urlString, method: .get)
        self.init(authRequest: authRequest)
    }
    
    func authRequest(urlString: String, method: Method) -> Networking {
        let url = URL(string: urlString)!
        
        let mutableURLRequest = NSMutableURLRequest(url: url)
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

*/
