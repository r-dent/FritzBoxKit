//
//  FritzBoxKit.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//
//  Copyright (c) 2018 Roman Gille, http://romangille.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import AEXML

open class FritzBox: NSObject {
    
    public typealias LoginCompletionBlock = (_ session: SessionInfo?, _ error: Error?) -> ()
    public typealias DeviceListCompletionBlock = (_ devices: [SmartHomeDevice], _ error: Error?) -> ()
    
    var host: String
    
    var userName: String?
    var password: String
    
    var sessionId: String?
    var sessionIdReceived: Date = .distantPast
    
    public init(host: String, user: String?, password: String) {
        self.host = host
        self.userName = user
        self.password = password
    }
    
    // MARK: - Requests.
    
    /// Authenticate with the Fritz!Box device.
    /// URL and user credentials are used from the initialization values.
    ///
    /// - Parameter completion: A block to handle the result/errors of the request.
    public func login(completion: LoginCompletionBlock?) {
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
            guard result.isSuccessfulOperation else {
                completion?(nil, FRZError(code: result.rawValue, reason: "Could not load challenge"))
                return
            }
            guard let challenge = sessionInfo?.challenge, !challenge.isEmpty else {
                completion?(nil, FRZError(reason: "Challenge not found"))
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
                completion?(nil, FRZError(reason: "Name or URL missing or malformed."))
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
    
    
    /// Load a list of all available smart home devices.
    ///
    /// - Parameter completion: A block to handle the result of the request.
    public func getDevices(completion: DeviceListCompletionBlock?) {
        guard
            let sessionId = self.sessionId,
            let url = URL(string: "\(host)/webservices/homeautoswitch.lua")
            else {
                completion?([], FRZError(reason: "Session missing"))
                return
        }
        
        let params: Parameters = [
            "sid": sessionId,
            "switchcmd": "getdevicelistinfos"
        ]
        typealias SmartHomeDeviceResource = Resource<[SmartHomeDevice]>
        
        let getDevices = SmartHomeDeviceResource(
            url: url,
            method: .get,
            params: params,
            parse: {
                guard let xml = try? AEXMLDocument(xml: $0) else {
                    throw SmartHomeDeviceResource.ParseError.mappingFailed
                }
                return xml.root.children.compactMap{ $0.xmlCompact }.compactMap{ SmartHomeDevice(XMLString: $0) }
        })
        
        load(getDevices) { (devices, result) in
            completion?(devices ?? [], (result.isSuccessfulOperation ? nil : FRZError(code: result.rawValue)))
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
