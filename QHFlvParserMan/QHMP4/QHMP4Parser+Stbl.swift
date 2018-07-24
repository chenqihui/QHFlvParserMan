//
//  QHMP4Parser+Stbl.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 stbl
 
 1.stsd
 2.stts
 3.stss
 4.ctts
 5.stsc
 6.stsz
 7.stco
 8.sgpd
 9.sbgp
 */

import Cocoa

func stsdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var sizeArr = [String]()
        for _ in 0..<Int(entryCount) {
            let size = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            let type = QHParserUtil.hexToString(data: data, startIndex: index + 4, length: 4)
            
            sizeArr.append("\(size), type = \(type)")
            
            index += Int(size)
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["size"] = sizeArr
    }
    return dicValue
}
