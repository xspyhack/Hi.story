//
//  WatchSessionService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import WatchKit
import WatchConnectivity

public class WatchSessionService: NSObject {
    
    public static let shared = WatchSessionService()
    
    private override init() {
        super.init()
    }

    private let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    public func start(withDelegate delegate: WCSessionDelegate) {
        
        if session?.delegate == nil {
            session?.delegate = delegate
        }
        session?.activate()
    }
    
    private var reachable: WCSession? {
        if let session = session, session.isReachable {
            return session
        } else {
            return nil
        }
    }
    
    public func update(withApplicationContext applicationContext: [String: Any]) {
        try? session?.updateApplicationContext(applicationContext)
    }
    
    @discardableResult
    public func transfer(userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return session?.transferUserInfo(userInfo)
    }
    
    @discardableResult
    public func transfer(file url: URL, metadata: [String: Any]? = nil) -> WCSessionFileTransfer? {
        return session?.transferFile(url, metadata: metadata)
    }
}
