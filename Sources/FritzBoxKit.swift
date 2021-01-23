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
    
    public typealias LoginCompletionBlock = (Result<SessionInfo, Error>) -> ()
    public typealias LogoutCompletionBlock = LoginCompletionBlock
    public typealias DeviceListCompletionBlock = (Result<[SmartHomeDevice], Error>) -> ()
    public typealias SwitchCompletionBlock = (Result<Bool, Error>) -> ()
    
    
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
    public func login(completion: @escaping LoginCompletionBlock) {
        let authChallenge = Resource<SessionInfo>(
            url: URL(string: "\(host)/login_sid.lua")!,
            method: .get,
            parse: {
                guard let sessionInfo = SessionInfo(XMLString: $0) else {
                    throw Resource<SessionInfo>.ParseError.mappingFailed
                }
                return sessionInfo
        })
        
        load(authChallenge) { result in

            guard case .success(let sessionInfo) = result, !sessionInfo.challenge.isEmpty else {
                completion(result)
                return
            }
            self.auth(sessionInfo.challenge, completion: completion)
        }
    }
    
    private func auth(_ challenge: String, completion: @escaping LoginCompletionBlock) {
        guard
            let name = userName,
            let url = URL(string: "\(host)/login_sid.lua")
        else {
            completion(.failure(AuthError.invalidCredendials))
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
        
        load(authentication) { result in

            if case .success(let sessionInfo) = result {
                guard sessionInfo.sid != "0000000000000000" else {
                    // username or password is invalid
                    completion(.failure(AuthError.invalidCredendials))
                    return
                }
                // Save session ID for later use.
                self.sessionId = sessionInfo.sid
                self.sessionIdReceived = Date()
            }
            completion(result)
        }
    }
    
    /// Log out from Fritz!Box device.
    /// URL is used from the initialization values.
    ///
    /// - Parameter completion: A block to handle the result/errors of the request.
    public func logout(completion: LogoutCompletionBlock?) {
        guard
            let sessionId = self.sessionId,
            let url = URL(string: "\(host)/login_sid.lua")
        else {
            completion?(.failure(AuthError.sessionMissing))
            return
        }
        
        let params: Parameters = [
            "sid": sessionId,
            "logout": "1"
        ]
        
        let logout = Resource<SessionInfo>(
            url: url,
            method: .get,
            params: params,
            parse: {
                guard let sessionInfo = SessionInfo(XMLString: $0) else {
                    throw Resource<SessionInfo>.ParseError.mappingFailed
                }
                return sessionInfo
        })
        load(logout) { result in
            // consider us as logged out in both cases success and failure
            
            // unset session ID.
            self.sessionId = nil
            self.sessionIdReceived = .distantPast
            completion?(result)
        }
    }
    
    
    /// Load a list of all available smart home devices.
    ///
    /// - Parameter completion: A block to handle the result of the request.
    public func getDevices(completion: @escaping DeviceListCompletionBlock) {
        guard
            let sessionId = self.sessionId,
            let url = URL(string: "\(host)/webservices/homeautoswitch.lua")
        else {
            completion(.failure(AuthError.sessionMissing))
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
        
        load(getDevices, completion: completion)
    }
    
    
    /// Switch smart home device on or off.
    ///
    /// - Parameters:
    ///     - identifier: The identification number (ain) of the device.
    ///     - on: true: on, false: off.
    ///     - completion: A block to handle the result of the switch.
    public func setSwitch(identifier: String, on: Bool, completion: @escaping SwitchCompletionBlock) {
        guard
            let sessionId = self.sessionId,
            let url = URL(string: "\(host)/webservices/homeautoswitch.lua")
        else {
            completion(.failure(AuthError.sessionMissing))
            return
        }
        
        let params: Parameters = [
            "sid": sessionId,
            "ain": identifier,
            "switchcmd": on ? "setswitchon" : "setswitchoff"
        ]
        typealias SmartHomeSwitchStateResource = Resource<Bool>
        
        let setSwitch = SmartHomeSwitchStateResource(
            url: url,
            method: .get,
            params: params,
            parse: {
                let result = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                guard result == "0" || result == "1" else { // "0" = off, "1" = on
                    throw SmartHomeSwitchStateResource.ParseError.mappingFailed
                }
                return result == "1"
        })
        
        load(setSwitch, completion: completion)
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
