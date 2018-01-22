//
//  Device.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 01.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

struct Device: XMLMappable  {
    
    var firmwareVersion: String = ""
    var id: String = ""
    var identifier: String = ""
    var manufacturer: String = ""
    var productName: String = ""
    var displayName: String = ""
    var temperature = Temperature()
    var hkr = RadiatorRegulator()
    
    var nodeName: String!
    
    init(map: XMLMap) {
    }
    
    mutating func mapping(map: XMLMap) {
        firmwareVersion <- map.attributes["fwversion"]
        id              <- map.attributes["id"]
        identifier      <- map.attributes["identifier"]
        manufacturer    <- map.attributes["manufacturer"]
        productName     <- map.attributes["productname"]
        displayName     <- map["name"]
        temperature     <- map["temperature"]
        hkr             <- map["hkr"]
    }
    
}

//<devicelist version="1">
//<device functionbitmask="320" fwversion="03.54" id="16" identifier="11959 0355192" manufacturer="AVM" productname="Comet DECT">
//<present>1</present>
//<name>Wohnzimmer</name>
//<temperature>
//<celsius>240</celsius>
//<offset>-20</offset>
//</temperature>
//<hkr>
//<tist>48</tist>
//<tsoll>53</tsoll>
//<absenk>32</absenk>
//<komfort>48</komfort>
//<lock>0</lock>
//<devicelock>0</devicelock>
//<errorcode>0</errorcode>
//<batterylow>0</batterylow>
//<nextchange>
//<endperiod>1513792800</endperiod>
//<tchange>48</tchange>
//</nextchange>
//</hkr>
//</device>
//</devicelist>

