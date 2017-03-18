//
//  Request.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 5/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hikit

enum HTTPMethod {
    case get
    case post
    case delete
    case put
}

protocol Authorizable {
    var token: String? { get }
}

extension Authorizable {
    var token: String? { return nil }
}

/*
 import Alamofire

 typealias RequestCompletionHandler = (URLRequest?, HTTPURLResponse?, AnyObject?, Error?) -> Void
 
 protocol Requestable {
 func request(_ urlString: String, method: HTTPMethod, parameters: JSONDictionary?, encoding: ParameterEncoding, completionHandler: RequestCompletionHandler?)
 func request(_ urlRequest: NSURLRequest, parameters: JSONDictionary?, completionHandler: RequestCompletionHandler?)
 func authRequest(_ urlString: String, method: HTTPMethod) -> NSMutableURLRequest
 }

struct Request: Requestable {

    static let shared = Request()
    
    func request(_ urlString: String, method: Alamofire.HTTPMethod, parameters: JSONDictionary? = nil, encoding: ParameterEncoding = URLEncoding.default, completionHandler: RequestCompletionHandler?) {
        
        Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding).responseJSON { response in
            completionHandler?(response.request, response.response, response.result.value as AnyObject?, response.result.error)
        }
    }
    
    func request(_ urlRequest: NSURLRequest, parameters: JSONDictionary? = nil, completionHandler: RequestCompletionHandler?) {
        let encodedURLRequest = try! Alamofire.URLEncoding().encode(urlRequest as! URLRequestConvertible, with: parameters)
        
        Alamofire.request(encodedURLRequest).responseJSON { response in
            completionHandler?(response.request, response.response, response.result.value as AnyObject?, response.result.error)
        }
    }
    
    func authRequest(_ urlString: String, method: Alamofire.HTTPMethod) -> NSMutableURLRequest {
        let url = URL(string: urlString)!
        
        let mutableURLRequest = NSMutableURLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue

        return mutableURLRequest
    }
    
    /*
    func sendAuthRequest<T: Serializable>(authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: Result<T> -> Void) {
        request(authRequest, parameters: parameters) { (_, _, responseJSON, error) in
            
            guard let json = responseJSON as? JSONDictionary, value = T(json: json)
                else {
                    completionHandler(.Failure(error?.localizedDescription))
                    return
            }
            
            completionHandler(.Success(value))
        }
    }
    
    func sendAuthRequest<T: Serializable>(authRequest: NSMutableURLRequest, parameters: JSONDictionary? = nil, completionHandler: Result<[T]> -> Void) {
        request(authRequest) { (_, _, responseJSON, error) in
            
            guard let json = responseJSON as? [JSONDictionary] else {
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
*/
