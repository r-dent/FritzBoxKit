//
//  XMLTemperatureTransform.swift
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
