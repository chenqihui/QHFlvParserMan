//
//  QHFlvParserUtil.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHFlvParserUtil: NSObject {
    
    class func hexToDecimal(data: Data, startIndex: Int, count: Int) -> UInt64 {
        var index = startIndex
        var number: UInt64 = 0
        for i in 0..<count {
            index += 1
            let v = UInt64(data[index])
            let g = 8 * (count - 1 - i)
            number += v * 1<<g
        }
        
        return number
    }
    
    class func hexToDouble(data: Data, startIndex: Int, count: Int) -> Double {
        let number: UInt64 = QHFlvParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: count)
        let numberValue = Double(bitPattern: number)
        
        return numberValue
    }
    
    class func hexToString(data: Data, startIndex: Int, length: uint) -> String {
        var index = startIndex
        var value = ""
        for _ in 0..<length {
            index += 1
            let v3 = uint(data[index])
            if (v3 >= 0x20 && v3 <= 0x7f) {
                value += String(format: "%c", v3)
            }
            else {
                value += "."
            }
        }
        return value
    }

}
