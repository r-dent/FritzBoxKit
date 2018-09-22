//
//  FritzBoxKit.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import Foundation
import AEXML

open class FritzBox: NSObject {
    
    typealias LoginCompletionBlock = (_ session: SessionInfo?, _ error: Error?) -> ()
    typealias DeviceListCompletionBlock = (_ devices: [Device], _ error: Error?) -> ()
    
    var host: String
    
    var userName: String?
    var password: String
    
    var sessionId: String?
    var sessionIdReceived: Date = .distantPast
    
    init(host: String, user: String?, password: String) {
        self.host = host
        self.userName = user
        self.password = password
    }
    
    // MARK: - Requests.
    
    func login(completion: LoginCompletionBlock?) {
        let authChallenge = Resource<SessionInfo>(
            url: URL(string: "\(host)/login_sid.lua")!,
            method: .get,
            parse: {
                guard let sessionInfo = SessionInfo(XMLString: $0) else {
                    throw Resource<SessionInfo>.ParseError.mappingFailed
                }
                return sessionInfo
        })
        
        load(authChallenge) { (sessionInfo, result) in
            guard let challenge = sessionInfo?.challenge, !challenge.isEmpty else {
                completion?(nil, NSError())
                return
            }
            self.auth(challenge, completion: completion)
        }
    }
    
    func auth(_ challenge: String, completion: LoginCompletionBlock?) {
        guard
            let name = userName,
            let url = URL(string: "\(host)/login_sid.lua")
            else {
                completion?(nil, NSError())
                return
        }
        
        let secret = md5(data: "\(challenge)-\(password)".data(using:.utf16LittleEndian)!)
        
        let params: Parameters = [
            "username": name,
            "response": "\(challenge)-\(secret)"
        ]
        
        let authentication = Resource<SessionInfo>(
            url: url,
            method: .get,
            params: params,
            parse: {
                guard let sessionInfo = SessionInfo(XMLString: $0) else {
                    throw Resource<SessionInfo>.ParseError.mappingFailed
                }
                return sessionInfo
        })
        
        load(authentication) { (sessionInfo, result) in
            // Save session ID for later use.
            self.sessionId = sessionInfo?.sid
            self.sessionIdReceived = Date()
            
            completion?(sessionInfo, nil)
        }
    }
    
    func getDevices(completion: DeviceListCompletionBlock?) {
        guard
            let sessionId = self.sessionId,
            let url = URL(string: "\(host)/webservices/homeautoswitch.lua")
            else {
                completion?([], NSError("Session missing"))
                return
        }
        
        let params: Parameters = [
            "sid": sessionId,
            "switchcmd": "getdevicelistinfos"
        ]
        
        let getDevices = Resource<[Device]>(
            url: url,
            method: .get,
            params: params,
            parse: {
                guard let xml = try? AEXMLDocument(xml: $0) else {
                    throw Resource<[Device]>.ParseError.mappingFailed
                }
                return xml.root.children.compactMap{ $0.xmlCompact }.compactMap{ Device(XMLString: $0) }
        })
        
        load(getDevices) { (devices, result) in
            completion?(devices ?? [], (result.isSuccessfulOperation ? nil : NSError(code: result.rawValue)))
        }
    }
}

extension FritzBox: URLSessionDelegate {
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            (challenge.protectionSpace.host == "fritz.box" || challenge.protectionSpace.host.hasSuffix("myfritz.net")),
            let trust = challenge.protectionSpace.serverTrust
        {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
}
