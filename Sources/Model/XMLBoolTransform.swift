//
//  XMLBoolTransform.swift
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
    
}

/// Object of Raw Representable type
public func <- (left: inout Bool, right: XMLMap) {
    left <- (right, FritzBox.XMLBoolTransform())
}

public func >>> (left: Bool, right: XMLMap) {
    left >>> (right, FritzBox.XMLBoolTransform())
}

/// Optional bject of Raw Representable type
public func <- (left: inout Bool?, right: XMLMap) {
    left <- (right, FritzBox.XMLBoolTransform())
}

public func >>> (left: Bool?, right: XMLMap) {
    left >>> (right, FritzBox.XMLBoolTransform())
}


