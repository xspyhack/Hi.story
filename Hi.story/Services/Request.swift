//
//  Request.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Alamofire
import Hikit

typealias CompletionHandler = (URLRequest?, HTTPURLResponse?, AnyObject?, NSError?) -> Void

protocol Requestable {
    func request(URLString: String, method: Alamofire.Method, parameters: JSONDictionary?, encoding: ParameterEncoding, completionHandler: CompletionHandler?)
    func request(_ URLRequest: NSMutableURLRequest, parameters: JSONDictionary?, completionHandler: CompletionHandler?)
    func authRequest(URLString: String, method: Alamofire.Method) -> NSMutableURLRequest
}

protocol Authorizable {
    var token: String? { get }
}

extension Authorizable {
    var token: String? { return Defaults.Authentication.token }
}

struct Request: Requestable {
    
    static let shareRequest = Request()
    
    func request(URLString: String, method: Alamofire.Method, parameters: JSONDictionary? = nil, encoding: ParameterEncoding = .URL, completionHandler: CompletionHandler?) {
        
        Alamofire.request(method, URLString, parameters: parameters, encoding: encoding).responseJSON { response in
            completionHandler?(response.request, response.response, response.result.value, response.result.error)
        }
    }
    
    func request(_ URLRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: CompletionHandler?) {
        let encodedURLRequest = Alamofire.ParameterEncoding.URLEncodedInURL.encode(URLRequest, parameters: parameters).0
        
        Alamofire.request(encodedURLRequest).responseJSON { response in
            completionHandler?(response.request, response.response, response.result.value, response.result.error)
        }
    }
    
    func authRequest(URLString: String, method: Alamofire.Method) -> NSMutableURLRequest {
        let URL = Foundation.URL(string: URLString)!
        
        let mutableURLRequest = NSMutableURLRequest(url: URL)
        mutableURLRequest.HTTPMethod = method.rawValue

        return mutableURLRequest
    }
    
    /*
    func sendAuthRequest<T: Serializable>(authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: Result<T> -> Void) {
        request(authRequest, parameters: parameters) { (_, _, responseJson, error) in
            
            guard let json = responseJson as? JSONDictionary, value = T(json: json)
                else {
                    completionHandler(.Failure(error?.localizedDescription))
                    return
            }
            
            completionHandler(.Success(value))
        }
    }
    
    func sendAuthRequest<T: Serializable>(authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: Result<[T]> -> Void) {
        request(authRequest) { (_, _, responseJson, error) in
            
            guard let json = responseJson as? [JSONDictionary] else {
                completionHandler(.Failure(error?.localizedDescription))
                return
            }
            
            let values = json.flatMap { T(json: $0) }
            completionHandler(.Success(values))
        }
    }
    
    func sendAuthRequest(authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: Result<Bool> -> Void) {
        request(authRequest, parameters: parameters) { (_, response, responseJSON, error) in
            if response?.statusCode < 300 && response?.statusCode >= 200 {
                completionHandler(.Success(true))
            } else if response?.statusCode == 404 {
                completionHandler(.Success(false))
            } else {
                completionHandler(.Failure(error?.localizedDescription))
            }
        }
    }
    */
}
