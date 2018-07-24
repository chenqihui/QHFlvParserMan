//
//  QHMP4Parser+Mdia.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 mdia
 
 1.mdhd
 2.hdlr
 3.minf
    container box
 */

import Cocoa

func mdhdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        // creation time
        index += 4
        // modification time
        index += 4
        let timescale = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        let trackTime = Double(duration)/Double(timescale)
        // language
        index += 2
        // pre-defined
        index += 2
        
        dicValue["flags"] = flags
        dicValue["timescale"] = timescale
        dicValue["duration"] = duration
        dicValue["trackTime"] = trackTime
    }
    return dicValue
}

func hdlrParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        // pre-defined
        index += 4
        let handlerType = QHParserUtil.hexToString(data: data, startIndex: index, length: 4)
        index += 4
        // reserved
        index += 12
        var end = uint(data[index + 1])
        var trackTypeName = ""
        while end != 0 {
            let name = QHParserUtil.hexToString(data: data, startIndex: index, length: 1)
            index += 1
            trackTypeName += name
            end = uint(data[index + 1])
        }
        
        dicValue["flags"] = flags
        dicValue["handlerType"] = handlerType
        dicValue["trackTypeName"] = trackTypeName
    }
    return dicValue
}
