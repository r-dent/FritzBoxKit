//
//  Helper.swift
//  Fritz!Box Kit
//
//  Created by Roman Gille on 28.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import Foundation
import CommonCrypto

func md5(data: Data) -> String {
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    
    _ = digestData.withUnsafeMutableBytes {digestBytes in
        data.withUnsafeBytes {bytes in
            CC_MD5(bytes, CC_LONG(data.count), digestBytes)
        }
    }
    
    return digestData.map { String(format: "%02hhx", $0) }.joined()
}
