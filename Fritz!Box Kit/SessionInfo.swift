//
//  SessionInfo.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import XMLMapper

struct SessionInfo: XMLMappable {
    
    var sid: String         = ""
    var challenge: String   = ""
    var blockTime: Int      = 0
    
    var nodeName: String! = "SessionInfo"
    
    init(map: XMLMap) {
    }
    
    mutating func mapping(map: XMLMap) {
        sid         <- map["SID"]
        challenge   <- map["Challenge"]
        blockTime   <- map["BlockTime"]
    }
    
}
