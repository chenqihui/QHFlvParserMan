//
//  QHMP4Parser+Moov.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 moov:
 
 1.mvhd
 2.trak
    container box
 3.udta
 
 */

import Cocoa

func mvhdParser(data: Data) -> [String: Any] {
    
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
        let rate1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let rate2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let volume1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        let volume2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        // reserved
        index += 10
        // matrix
        index += 36
        // pre-defined
        index += 24
        let nextTrackId = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        dicValue["flags"] = flags
        dicValue["timescale"] = timescale
        dicValue["duration"] = duration
        dicValue["trackTime"] = trackTime
        dicValue["rate"] = "\(rate1).\(rate2)"
        dicValue["volume"] = "\(volume1).\(volume2)"
        dicValue["nextTrackId"] = nextTrackId
    }
    return dicValue
}
