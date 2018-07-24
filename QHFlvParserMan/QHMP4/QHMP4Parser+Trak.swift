//
//  QHMP4Parser+Trak.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 trak
 
 1.tkhd
 2.edts
 3.mdia
    container box
 */

import Cocoa

func tkhdParser(data: Data) -> [String: Any] {
    
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
        let trackId = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // reserved
        index += 4
        let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // reserved
        index += 8
        let layer = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let alternateGroup = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let volume1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        let volume2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        // reserved
        index += 2
        // matrix
        index += 36
        let width1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let width2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let height1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let height2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        
        dicValue["flags"] = flags
        dicValue["trackId"] = trackId
        dicValue["duration"] = duration
        dicValue["layer"] = layer
        dicValue["alternateGroup"] = alternateGroup
        dicValue["volume"] = "\(volume1).\(volume2)"
        dicValue["width"] = "\(width1).\(width2)"
        dicValue["height"] = "\(height1).\(height2)"
    }
    return dicValue
}
