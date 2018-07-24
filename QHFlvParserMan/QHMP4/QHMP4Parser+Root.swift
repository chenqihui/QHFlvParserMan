//
//  QHMP4Parser+Root.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

/*
 root:
 
 1.ftyp
 2.moov
    container box
 3.free
    ignore
 4.mdat
 */

extension QHMP4Parser {
    
    func ftypParser(data: Data) -> [String: Any] {
        
        var dicValue = [String: Any]()
        
        let length = 4
        let count = data.count / length
        for index in 0..<count {
            let startIndex = data.startIndex - 1 + length * index
            if index == 1 {
                let value = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: length)
                dicValue["minorVersion"] = value
            }
            else {
                let value = QHParserUtil.hexToString(data: data, startIndex: startIndex, length: uint(length))
                if index == 0 {
                    dicValue["majorBrand"] = value
                }
                else {
                    if var arr = dicValue["compatibleBrands"] as? [Any] {
                        arr.append(value)
                        dicValue["compatibleBrands"] = arr
                    }
                    else {
                        let arr = [value]
                        dicValue["compatibleBrands"] = arr
                    }
                }
            }
        }
        return dicValue
    }
}
