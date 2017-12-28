//
//  ViewController.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 25.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import UIKit
import AEXML

class ViewController: UIViewController, URLSessionDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let host = "https://fritz.box"
    let port = "46048"
    let username = ""
    let password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let challenge = "1a16a872"
        let secret = md5(data: "\(challenge)-\(password)".data(using:.utf16LittleEndian)!)
        let response = "\(challenge)-\(secret)"
        print(response)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func runChallenge(_ sender: Any) {
        let endpoint = "login_sid.lua"
        
        guard let url = URL(string: "\(host):\(port)/\(endpoint)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            if let xml = try? AEXMLDocument(xml: data) {
                let challenge = xml.root["Challenge"].string
                print(challenge)
                self.auth(challenge)
            }
            
            
        }
        task.resume()
    }
    
    func auth(_ challenge: String) {
        let endpoint = "login_sid.lua"
        
        let secret = md5(data: "\(challenge)-\(password)".data(using:.utf16LittleEndian)!)
        let response = "\(challenge)-\(secret)"
        
        guard let url = URL(string: "\(host):\(port)/\(endpoint)?username=\(username)&response=\(response)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            if let xml = try? AEXMLDocument(xml: data) {
                let rights = xml.root["Rights"].string
                print(rights)
            }
            
            
        }
        task.resume()
    }
    
    func md5(data: Data) -> String {
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {bytes in
                CC_MD5(bytes, CC_LONG(data.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // MARK: - URLSessionDelegate
    
    func urlSession(
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

