//
//  SessionInfo.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import XMLMapper

extension FritzBox {
    
    public struct SessionInfo: XMLMappable {
        
        public var sid: String         = ""
        public var challenge: String   = ""
        var blockTime: Int      = 0
        
        public var nodeName: String! = "SessionInfo"
        
        public init(map: XMLMap) {
        }
        
        mutating public func mapping(map: XMLMap) {
            sid         <- map["SID"]
            challenge   <- map["Challenge"]
            blockTime   <- map["BlockTime"]
        }
        
    }
    
}
