//
//  RadiatorRegulator.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

struct RadiatorRegulator: XMLMappable  {
    
    enum ErrorCode: Int {
        case
        none                    = 0,
        /// Keine Adaptierung möglich. Gerät korrekt am Heizkörper montiert?
        adoptionProblem         = 1,
        /// Ventilhub zu kurz oder Batterieleistung zu schwach.
        /// Ventilstößel per Hand mehrmals öfnen und schließen oder neue Batterien einsetzen.
        ventLow                 = 2,
        /// Keine Ventilbewegung möglich. Ventilstößel frei?
        movementProblem         = 3,
        preparingInstallation   = 4,
        /// Der Heizkörperregler ist im Installationsmodus und kann auf das Heizungsventil montiert werden.
        installationMode        = 5,
        adjusting               = 6
    }
    
    var target: Double = 0
    var current: Double = 0
    var high: Double = 0
    var low: Double = 0
    
    var batteryLow: Bool = false
    var locked: Bool?
    var lockedByDevice: Bool?
    var error: ErrorCode = .none
    
    var nodeName: String!
    
    init() {}
    
    init(map: XMLMap) {
    }
    
    mutating func mapping(map: XMLMap) {
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

