//
//  RadiatorRegulator.swift
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
    
    public struct RadiatorRegulator: XMLMappable  {
        
        public enum ErrorCode: String {
            case
            noError                 = "0",
            /// Keine Adaptierung möglich. Gerät korrekt am Heizkörper montiert?
            adoptionProblem         = "1",
            /// Ventilhub zu kurz oder Batterieleistung zu schwach.
            /// Ventilstößel per Hand mehrmals öfnen und schließen oder neue Batterien einsetzen.
            ventLow                 = "2",
            /// Keine Ventilbewegung möglich. Ventilstößel frei?
            movementProblem         = "3",
            preparingInstallation   = "4",
            /// Der Heizkörperregler ist im Installationsmodus und kann auf das Heizungsventil montiert werden.
            installationMode        = "5",
            adjusting               = "6"
        }
        
        public var target: Double = 0
        public var current: Double = 0
        public var high: Double = 0
        public var low: Double = 0
        
        public var batteryLow: Bool = false
        public var locked: Bool?
        public var lockedByDevice: Bool?
        public var error: ErrorCode = .noError
        
        public var nodeName: String!
        
        init() {}
        
        public init(map: XMLMap) {
        }
        
        mutating public func mapping(map: XMLMap) {
            target          <- (map["tsoll"], XMLFloatTransform(mode: .temperature))
            current         <- (map["tist"], XMLFloatTransform(mode: .temperature))
            high            <- (map["komfort"], XMLFloatTransform(mode: .temperature))
            low             <- (map["absenk"], XMLFloatTransform(mode: .temperature))
            batteryLow      <- map["batterylow"]
            locked          <- map["lock"]
            lockedByDevice  <- map["devicelock"]
            error           <- map["errorcode"]
        }
        
    }
    
}
