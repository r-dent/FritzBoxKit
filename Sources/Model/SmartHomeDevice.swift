//
//  SmartHomeDevice.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 01.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

extension FritzBox {
    
    public struct SmartHomeDevice: XMLMappable  {
        
        public struct Feature: OptionSet {
            
            public let rawValue: Int
            
            public init (rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let alarmSensor          = Feature(rawValue: 1 << 4)
            public static let radiatorRegulator    = Feature(rawValue: 1 << 6)
            public static let energySensor         = Feature(rawValue: 1 << 7)
            public static let temperatureSensor    = Feature(rawValue: 1 << 8)
            public static let powerSwitch          = Feature(rawValue: 1 << 9)
            public static let dectRepeater         = Feature(rawValue: 1 << 10)
            
        }
        
        public var firmwareVersion: String = ""
        public var id: String = ""
        public var identifier: String = ""
        public var features: Feature = []
        public var manufacturer: String = ""
        public var productName: String = ""
        public var displayName: String = ""
        
        public var temperature: Temperature?
        public var hkr: RadiatorRegulator?
        
        public var nodeName: String!
        
        public init(map: XMLMap) {
        }
        
        mutating public func mapping(map: XMLMap) {
            firmwareVersion <- map.attributes["fwversion"]
            id              <- map.attributes["id"]
            identifier      <- map.attributes["identifier"]
            manufacturer    <- map.attributes["manufacturer"]
            productName     <- map.attributes["productname"]
            displayName     <- map["name"]
            
            temperature     <- map["temperature"]
            hkr             <- map["hkr"]
            
            let featureTransform = XMLTransformOf<Feature, String>(fromXML: { (value) -> Feature? in
                return value.flatMap{ Int($0) }.flatMap{ Feature(rawValue: $0) }
            }, toXML: {
                $0.flatMap{ String(format: "%i", $0.rawValue) }
            })
            features        <- (map.attributes["functionbitmask"], featureTransform)
            
        }
        
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

