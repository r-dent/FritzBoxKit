//
//  PowerSwitch.swift
//  FritzBoxKit
//
//  Created by Roman Gille on 27.09.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

extension FritzBox {
    
    public struct PowerSwitch: XMLMappable  {
        
        public enum Mode: String {
            case auto
            case manual = "manuell"
        }
        
        public var state: Bool?
        public var mode: Mode?
        public var lockedBySoftware: Bool?
        public var lockedByDevice: Bool?
        
        public var nodeName: String! = "switch"
        
        init() {}
        
        public init(map: XMLMap) {
        }
        
        mutating public func mapping(map: XMLMap) {
            state               <- map["state"]
            mode                <- map["mode"]
            lockedBySoftware    <- map["lock"]
            lockedByDevice      <- map["devicelock"]
        }
        
    }
    
}
