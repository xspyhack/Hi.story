//
//  Router.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 18/03/2018.
//  Copyright © 2018 bl4ckra1sond3tre. All rights reserved.
//

import Foundation
import Hilambda
import Argo

public class Router: Routing {
    
    public static let shared = Router()
    
    public var hosts: [String] = []
    
    public var schemes: [String] = []
    
    public static var context: Context? {
        get {
            return shared.context
        }
        set {
            shared.context = newValue
        }
    }
    
    public var context: Context?
    
    private var routes: Set<Route> = []
    
    public static func canRoute(_ url: URL) -> Bool {
        return shared.canRoute(url)
    }
    
    public func canRoute(_ url: URL) -> Bool {
        return matched(url) != nil
    }
    
    public static func route(_ url: URL, withParams params: Params? = nil, context: Context? = nil) {
        shared.route(url, withParams: params)
    }
    
    public func route(_ url: URL, withParams params: Params? = nil, context: Context? = nil) {
        if let params = params {
            assert(params.isValided, "Params must be object type")
        }
        
        self.context = context
        routes.forEach { route in
            guard let param = parsed(url: url, with: route.pattern) else {
                return
            }
            route.handler?(params.map { try! $0 + param } ?? param)
        }
    }
    
    public static func add(_ route: Route) {
        shared.add(route)
    }
    
    public func add(_ route: Route) {
        routes.insert(route)
    }
    
    public static func remove(_ route: Route) {
        shared.remove(route)
    }
    
    public func remove(_ route: Route) {
        routes.remove(route)
    }
    
    public static func match(_ url: URL) -> Params? {
        return shared.match(url)
    }
    
    public func match(_ url: URL) -> Params? {
        return routes.reduce(nil) { (accum, route) in
            return accum ?? parsed(url: url, with: route.pattern)
        }
    }
    
    public func matched(_ url: URL) -> Route? {
        return routes.reduce(nil) { (accum, route) -> Route? in
            return accum ?? parsed(url: url, with: route.pattern).map { _ in route }
        }
    }
}


// MARK: Helpers


/**
 url: www.blessingsoft.com/feed/233
 pattern: /feed/:id
 -> [id: 233]
 
 url: www.blessingsoft.com/storybook/233/story/2
 pattern: /storybook/:bookid/story/:storyid
 -> [bookid: 233, storyid: 2]
 
 url: www.blessingsoft.com/feed
 pattern: /feed
 -> [:]
 */


/// Parse url
///
/// - Parameters:
///   - url: www.blessingsoft.com/feed/233
///   - pattern: /feed/:id
/// - Returns: [id: 233]
private func parsed(url: URL, with pattern: String) -> Params? {
    
    let isRecognizedHost = Router.shared.hosts.reduce(false) { acc, host in
        acc || url.host.map { $0.hasPrefix(host) } == .some(true)
    }
    
    let isRecognizedScheme = Router.shared.schemes.reduce(false) { acc, scheme in
        acc || url.scheme.map { $0 == scheme } == .some(true)
    }
    
    guard isRecognizedHost || isRecognizedScheme else { return nil }
    
    let URLString = isRecognizedScheme ? url.absoluteString.replacingOccurrences(of: "//", with: "///") : url.absoluteString
    
    let url = URL(string: URLString) ?? url
    
    // [storybook, :bookid, story, storyid]
    let patternComponents = pattern
        .components(separatedBy: "/")
        .filter { $0 != "" }
    
    // [storybook, 233, story, 2]
    let urlComponents = url
        .path
        .components(separatedBy: "/")
        .filter { $0 != "" && !$0.hasPrefix("?") }
    
    guard patternComponents.count == urlComponents.count else { return nil }
    
    var params: [String: String] = [:] // [bookid: 233, storyid: 2]
    
    for (patternComponent, urlComponent) in zip(patternComponents, urlComponents) {
        if patternComponent.hasPrefix(":") {
            // matched a token
            let paramName = String(patternComponent.dropFirst()) // bookid
            params[paramName] = urlComponent // [bookid: 233]
        } else if patternComponent != urlComponent {
            return nil
        }
    }
    
    // get query
    URLComponents(url: url, resolvingAgainstBaseURL: false)?
        .queryItems?
        .forEach { item in
            params[item.name] = item.value
        }
    
    var object: [String: Params] = [:]
    params.forEach { key, value in
        object[key] = .string(value)
    }
    
    return .object(object)
}

private func oneToBool(_ string: String?) -> Decoded<Bool?> {
    return string.flatMap { Int($0) }.map { $0 == 1 }.map(Decoded.success) ?? .success(nil)
}

private func stringToInt(_ string: String) -> Decoded<Int> {
    return Int(string).map(Decoded.success) ?? .failure(.custom("Could not parse string into int."))
}

extension Dictionary {
    private func restrict(keys: Set<Key>) -> Dictionary {
        var result = Dictionary()
        self.forEach { key, value in
            if keys.contains(key) {
                result[key] = value
            }
        }
        return result
    }
}
