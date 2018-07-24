//
//  QHMP4Parser+Minf.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 minf
 
 1.vmhd
 2.smhd
 3.dinf
    container box
 4.stbl
    container box
 */

import Cocoa

func vmhdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let graphicsMode = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let red = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let green = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let blue = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        
        dicValue["flags"] = flags
        dicValue["graphicsMode"] = graphicsMode
        dicValue["opcolor"] = "{\(red), \(green), \(blue)}"
    }
    return dicValue
}

func smhdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let balance1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let balance2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        // reserved
        index += 2
        
        dicValue["flags"] = flags
        dicValue["balance"] = "\(balance1).\(balance2)"
    }
    return dicValue
}
