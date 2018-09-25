//
//  XMLTemperatureTransform.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

extension FritzBox {
    
    open class XMLTemperatureTransform: XMLTransformType {
        public typealias Object = Double
        public typealias XML = Int
        
        enum Mode {
            case
            tenth,
            half
        }
        
        let mode: Mode
        
        init(mode: Mode) {
            self.mode = mode
        }
        
        open func transformFromXML(_ value: Any?) -> Double? {
            guard let textNode = value as? String, let intValue = Int(textNode) else {
                return nil
            }
            
            if mode == .tenth {
                return Double(intValue) / 10.0
            }
            else {
                if intValue == 254 { return Double.greatestFiniteMagnitude } // On.
                if intValue == 253 { return 0 } // Off.
                let halfValue = Double(intValue) / 2.0
                return min(max(halfValue, 8), 28) // Limit values to a range between 8 and 28° C.
            }
        }
        
        open func transformToXML(_ value: Double?) -> Int? {
            guard let val = value else {
                return nil
            }
            return Int(round(val * 10))
        }
    }
    
}
