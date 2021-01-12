//
//  XMLFloatTransform.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
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

import Foundation
import XMLMapper

extension FritzBox {
    
    open class XMLFloatTransform: XMLTransformType {
        public typealias Object = Double
        public typealias XML = Int
        
        /// Defines in which way the Integer value is mapped to Double.
        enum Mode {
            case
            /// Devides the Integer value by 10.
            tenth,
            /// Devides the Integer value by 1000.
            thousand,
            /// Uses following definition for mapping (See AHA-HTTP-Interface.pdf):
            /// Wertebereich: 0x10 – 0x38
            /// 16 – 56 (8 bis 28°C), 16 <= 8°C, 17 = 8,5°C...... 56 >= 28°C, 254 = ON , 253 = OFF
            temperature
        }
        
        let mode: Mode
        
        init(mode: Mode) {
            self.mode = mode
        }
        
        open func transformFromXML(_ value: Any?) -> Double? {
            guard let textNode = value as? String, let intValue = Int(textNode) else {
                return nil
            }
            
            switch mode {
            case .tenth:
                return Double(intValue) / 10.0
                
            case .thousand:
                return Double(intValue) / 1000.0
                
            case .temperature:
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
            switch mode {
            case .tenth:
                return Int(round(val * 10))
                
            case .thousand:
                return Int(round(val * 1000))
                
            case .temperature:
                if val == Double.greatestFiniteMagnitude { return 254 } // On.
                if val == 0 { return 253 } // Off.
                let x2Value = min(max(val, 8), 28) * 2 // Limit values to a range between 8 and 28° C.
                return Int(round(x2Value)) 
            }
        }
    }
    
}
