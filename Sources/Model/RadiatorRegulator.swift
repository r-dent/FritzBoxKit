//
//  RadiatorRegulator.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
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
            target          <- (map["tsoll"], XMLTemperatureTransform(mode: .half))
            current         <- (map["tist"], XMLTemperatureTransform(mode: .half))
            high            <- (map["komfort"], XMLTemperatureTransform(mode: .half))
            low             <- (map["absenk"], XMLTemperatureTransform(mode: .half))
            batteryLow      <- map["batterylow"]
            locked          <- map["lock"]
            lockedByDevice  <- map["devicelock"]
            error           <- map["errorcode"]
        }
        
    }
    
}
