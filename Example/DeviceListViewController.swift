//
//  ViewController.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 25.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import UIKit
import FritzBoxKit

class DeviceListViewController: UITableViewController, Instantiatable {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var fritzBox: FritzBox!
    var devices: [FritzBox.SmartHomeDevice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(loadDevices), for: .valueChanged)
        refreshControl!.beginRefreshing()
        
        loadDevices()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadDevices() {
        fritzBox.getDevices(completion: { [weak self] result in

            switch result {

            case .success(let devices):
                print("Info: \(String(describing: devices))")

                self?.devices = devices

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }

            case .failure(let error):
                print("Device Error: \(error)")
                self?.refreshControl?.endRefreshing()
            }
        })
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = devices[indexPath.row]
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "deviceCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "deviceCell")
        }
        
        let switchOnOff: String
        if let switchState = device.powerSwitch?.state {
            switchOnOff = switchState ? "ON" : "OFF"
        } else {
            switchOnOff = "-"
        }
        
        cell.textLabel?.text = String(format: "%@ - %.2f - %@", device.displayName, device.temperature?.celsius ?? 0, switchOnOff)
        cell.detailTextLabel?.text = device.identifier
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        
        guard let switchState = device.powerSwitch?.state else {
            print("device \(device.displayName) is not switchable")
            return
        }
        fritzBox.setSwitch(identifier: device.identifier, on: !switchState, completion: { [weak self] result in

            switch result {

            case .success(let switchState):
                print("Info: device \(device.displayName) is now \(switchState ? "on" : "off")")

                self?.devices[indexPath.row].powerSwitch?.state = switchState

            case .failure(let error):
                print("Switch Error: \(error)")
            }
            
            DispatchQueue.main.async {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        })
    }
}

