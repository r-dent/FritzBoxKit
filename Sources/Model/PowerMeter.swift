////
//  PowerMeter.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 08.10.18.
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
    
    public struct PowerMeter: XMLMappable  {
        
        /// Current power in Watts.
        public var currentPower: Double = 0
        /// Absolute consumption since activation in Wh.
        public var energy: Double = 0
        /// Current voltage in volts.
        public var currentVoltage: Double = 0
        
        public var nodeName: String! = "powermeter"
        
        init() {}
        
        public init(map: XMLMap) {
        }
        
        mutating public func mapping(map: XMLMap) {
            currentPower    <- (map["power"], XMLFloatTransform(mode: .thousand))
            energy          <- (map["energy"], XMLFloatTransform(mode: .thousand))
            currentVoltage  <- (map["voltage"], XMLFloatTransform(mode: .thousand))
        }
        
    }
    
}

