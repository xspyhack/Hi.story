//
//  WatchSessionService.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 15/10/2016.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import WatchConnectivity

public class WatchSessionService: NSObject {
    
    static let shared = WatchSessionService()
    
    private override init() {
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    public func start() {

        session?.delegate = self
        session?.activate()
    }
    
    private var valid: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        } else {
            return nil
        }
    }
    
    private var isReachable: WCSession? {
        if let session = session, session.isReachable {
            return session
        } else {
            return nil
        }
    }
    
    @discardableResult
    public func transfer(userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return valid?.transferUserInfo(userInfo)
    }
    
    @discardableResult
    public func transfer(file url: URL, metadata: [String: Any]? = nil) -> WCSessionFileTransfer? {
        return valid?.transferFile(url, metadata: metadata)
    }
    
    @discardableResult
    public func transfer(currentComplicationUserInfo userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        return valid?.transferCurrentComplicationUserInfo(userInfo)
    }
}

extension WatchSessionService: WCSessionDelegate {
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    /** ------------------------- iOS App State For Watch ------------------------ */
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    public func sessionDidDeactivate(_ session: WCSession){
        
    }
    
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        //
    }
}
