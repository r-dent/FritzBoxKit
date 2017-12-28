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
    
    var manager: FritzBox!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = FritzBox(
            host: "https://.myfritz.net:46048",
            user: "",
            password: ""
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func runChallenge(_ sender: Any) {
        manager.login { (info, error) in
            if let error = error {
                print("Error: \(error)")
            }
            else {
                print("Info: \(info)")
            }
        }
    }
    

}

