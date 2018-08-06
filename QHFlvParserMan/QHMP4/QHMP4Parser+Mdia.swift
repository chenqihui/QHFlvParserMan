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
 定义了媒体的特性，例如time scale和duration
 2.hdlr
 Handler reference atom 定义了描述此媒体数据的media handler component，类型是'hdlr'。在过去，handler reference atom也可以用来数据引用，但是现在，已经不允许这样使用了。一个media atom内的handler atom解释了媒体流的播放过程。例如，一个视频handler处理一个video track。
 3.minf
    container box
 edia information atoms的类型是'minf'，存储了解释该track的媒体数据的handler-specific的信息。media handler用这些信息将媒体时间映射到媒体数据，并进行处理。它是一个容器atom，包含其他的子atom。
 
 这些信息是与媒体定义的数据类型特别对应的，而且media information atoms 的格式和内容也是与解释此媒体数据流的media handler 密切相关的。其他的media handler不知道如何解释这些信息。
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
        // creation time 起始时间。基准时间是1904-1-1 0:00 AM
        index += 4
        // modification time 修订时间。基准时间是1904-1-1 0:00 AM
        index += 4
        let timescale = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // 该track的长度
        let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // 该track的时长
        let trackDuration = Double(duration)/Double(timescale)
        let trackTime = Double(duration)/Double(timescale)
        // language 媒体的语言码。最高位为0，后面15位为3个字符（见ISO 639-2/T标准中定义）
        index += 2
        // pre-defined
        index += 2
        
        dicValue["flags"] = flags
        dicValue["timescale"] = timescale
        dicValue["duration"] = duration
        dicValue["trackTime"] = trackTime
        dicValue["trackDuration"] = trackDuration
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
        /*
         在media box中，该值为4个字符：
         “vide”— video track
         “soun”— audio track
         “hint”— hint track
         */
        let handlerType = QHParserUtil.hexToString(data: data, startIndex: index, length: 4)
        index += 4
        // reserved
        index += 12
        var end = uint(data[index + 1])
        // track type name，长度不定，也可以为0，以‘\0’结尾的字符串
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
