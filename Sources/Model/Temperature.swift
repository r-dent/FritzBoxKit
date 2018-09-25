//
//  Temperature.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

extension FritzBox {
    
    public struct Temperature: XMLMappable  {
        
        public var celsius: Double = 0
        public var offset: Double = 0
        
        public var nodeName: String!
        
        init() {}
        
        public init(map: XMLMap) {
        }
        
        mutating public func mapping(map: XMLMap) {
            celsius <- (map["celsius"], XMLTemperatureTransform(mode: .tenth))
            offset <- map["offset"]
        }
        
    }
    
}
