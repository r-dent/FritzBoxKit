//
//  SmartHomeDevice.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 01.01.18.
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
        public var powerSwitch: PowerSwitch?
        public var powerMeter: PowerMeter?
        
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
            powerSwitch     <- map["switch"]
            powerMeter      <- map["powermeter"]
            
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

