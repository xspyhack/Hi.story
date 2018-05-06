//
//  WatchSessionService.swift
//  Hi.kit
//
//  Created by bl4ckra1sond3tre on 15/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import WatchConnectivity

public class WatchSessionService: NSObject {
    
    public static let shared = WatchSessionService()
    
    private override init() {
        super.init()
    }
    
    private lazy var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    public func start(withDelegate delegate: WCSessionDelegate) {

        if session?.delegate == nil {
            session?.delegate = delegate
        }
        
        if session?.activationState == .notActivated {
            session?.activate()
        }
    }
    
    public var activationState: WCSessionActivationState? {
        return session?.activationState
    }
    
    #if os(iOS)
    public var isPaired: Bool {
        return session?.isPaired ?? false
    }
    
    public var isInstalled: Bool {
        return session?.isWatchAppInstalled ?? false
    }
    #endif
    
    private var valid: WCSession? {
        #if os(iOS)
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        } else {
            return nil
        }
        #elseif os(watchOS)
            return session
        #endif
    }
    
    private var reachable: WCSession? {
        if let session = session, session.isReachable {
            return session
        } else {
            return nil
        }
    }
   
    /**
     Update ApplicationContext
     
     - parameter withApplicationContext: Plist Type Dictionary
     */
    public func update(withApplicationContext applicationContext: [String: Any]) throws {
       
        assert(!unavalibleContext(applicationContext), "Context only support plist type")
        
        try session?.updateApplicationContext(applicationContext)
    }
    
    private func unavalibleContext(_ context: [String: Any]) -> Bool {
        let invalid = (context.values.filter {
            !($0 is Array<Any>) && !($0 is [String: Any]) && !($0 is Date) && !($0 is NSNumber) && !($0 is String) && !($0 is Data) && !($0 is Bool)
        })
        
        return invalid.count > 0
    }
    
    public func send(message: [String: Any]) {
        valid?.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    @discardableResult
    public func transfer(userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return valid?.transferUserInfo(userInfo)
    }
    
    @discardableResult
    public func transfer(file url: URL, metadata: [String: Any]? = nil) -> WCSessionFileTransfer? {
        return valid?.transferFile(url, metadata: metadata)
    }
    
    #if os(iOS)
    @discardableResult
    public func transfer(currentComplicationUserInfo userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return valid?.transferCurrentComplicationUserInfo(userInfo)
    }
    #endif
}

