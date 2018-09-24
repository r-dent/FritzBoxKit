//
//  Error+Ext.swift
//  dlh
//
//  Created by Roman Gille on 27.11.17.
//  Copyright © 2017 WEBTEAM LEIPZIG GmbH. All rights reserved.
//

import Foundation

extension NSError {
    
    convenience init(domain: String = "fritzboxkit", code:Int = 0, reason: String? = nil) {
        self.init(domain: domain, code: code, userInfo: reason.flatMap{ [NSLocalizedFailureReasonErrorKey: $0] })
    }
    
}
