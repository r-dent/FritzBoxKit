//
//  XMLBoolTransform.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 22.01.18.
//  Copyright © 2018 Roman Gille. All rights reserved.
//

import XMLMapper

open class XMLBoolTransform: XMLTransformType {
    public typealias Object = Bool
    public typealias XML = Int
    
    open func transformFromXML(_ value: Any?) -> Bool? {
        return (value as? String).map{ $0 == "1" }
    }
    
    open func transformToXML(_ value: Bool?) -> Int? {
        return value.map{ $0 ? 1 : 0 }
    }
}

/// Object of Raw Representable type
public func <- (left: inout Bool, right: XMLMap) {
    left <- (right, XMLBoolTransform())
}

public func >>> (left: Bool, right: XMLMap) {
    left >>> (right, XMLBoolTransform())
}

/// Optional bject of Raw Representable type
public func <- (left: inout Bool?, right: XMLMap) {
    left <- (right, XMLBoolTransform())
}

public func >>> (left: Bool?, right: XMLMap) {
    left >>> (right, XMLBoolTransform())
}


