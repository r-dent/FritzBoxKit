//
//  Temperature.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

extension FritzBox {
    
    struct Temperature: XMLMappable  {
        
        var celsius: Double = 0
        var offset: Double = 0
        
        var nodeName: String!
        
        init() {}
        
        init(map: XMLMap) {
        }
        
        mutating func mapping(map: XMLMap) {
            celsius <- (map["celsius"], XMLTemperatureTransform(mode: .tenth))
            offset <- map["offset"]
        }
        
    }
    
}
