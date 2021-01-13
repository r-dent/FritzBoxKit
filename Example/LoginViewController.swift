//
//  LoginViewController.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 24.09.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import UIKit
import FritzBoxKit

class LoginViewController: UIViewController {

    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var blockerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultValues = loadDefaults()
        
        urlField.text = defaultValues.url
        nameField.text = defaultValues.userName
        passwordField.text = defaultValues.password
    }
    
    func showDevices(of fritzBox: FritzBox) {
        let vc: DeviceListViewController = .instantiate()
        vc.fritzBox = fritzBox
        DispatchQueue.main.sync {
            present(vc, animated: true)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard
            let url = urlField.text, url.count > 0,
            let name = nameField.text, name.count > 0,
            let password = passwordField.text, password.count > 0
            else {
            return
        }
        blockerView.isHidden = false
        
        let fritzBox = FritzBox(
            host: url,
            user: name,
            password: password
        )
        
        fritzBox.login { [weak self] result in
            DispatchQueue.main.async {
                self?.blockerView.isHidden = true
            }

            switch result {

            case .success(let info):
                self?.rememberValues(url: url, username: name, password: password)
                print("Info: \(String(describing: info))")
                self?.showDevices(of: fritzBox)

            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func rememberValues(url: String, username name: String, password pw: String) {
        let defaults = UserDefaults.standard
        defaults.set(url, forKey: UserDefaults.Keys.fritzBoxUrl)
        defaults.set(name, forKey: UserDefaults.Keys.fritzBoxUserName)
        defaults.set(pw, forKey: UserDefaults.Keys.fritzBoxPassword)
        defaults.synchronize()
    }
    
    func loadDefaults() -> (url: String?, userName: String?, password: String?) {
        let defaults = UserDefaults.standard
        return (
            url: defaults.string(forKey: UserDefaults.Keys.fritzBoxUrl),
            userName: defaults.string(forKey: UserDefaults.Keys.fritzBoxUserName),
            password: defaults.string(forKey: UserDefaults.Keys.fritzBoxPassword)
        )
    }

}

extension UserDefaults {
    enum Keys {
        static let fritzBoxUrl = "fritzBoxUrl"
        static let fritzBoxUserName = "fritzBoxUserName"
        static let fritzBoxPassword = "fritzBoxPassword"
    }
}
