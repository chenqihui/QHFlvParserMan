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
 每个trak都包含了一个track header atom. The track header atom 定义了一个track的特性，例如时间，空间和音量信息
 2.edts
    container box
 Edit atoms 定义了创建movie中一个track的一部分媒体。所有的edit都在一个表里面，包括每一部分的时间偏移量和长度。Edit atoms 的类型是'edts'。如果没有该表，则此track会被立即播放。一个空的edit用来偏移track的起始时间。
 
 如果没有edit atom 或edit list atom，则此track使用全部媒体。
 
 Edit atoms是一个容器atom，本身没有特别的字段，需要子atom来进一步说明有效的内容
 2.1.elst
 Edit list atom 用来映射movie的时间到此track media的时间。所有信息在一个edit list 表中，见下图。Edit list atoms 的类型是'elst'.
 3.mdia
    container box
 Media atoms定义了track的媒体类型和sample数据，例如音频或视频，描述sample数据的media handler component，media timescale and track duration以及media-and-track-specific 信息，例如音量和图形模式。它也可以包含一个引用，指明媒体数据存储在另一个文件中。也可以包含一个sample table atoms，指明sample description, duration, and byte offset from the data reference for each media sample.
 
 Media atom 的类型是'mdia'。它是一个容器atom，必须包含一个media header atom ('mdhd')，一个handler reference ('hdlr')，一个媒体信息引用('minf').
 */

import Cocoa

func tkhdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        /*
         按位或操作结果值，预定义如下：
         0x000001 track_enabled，否则该track不被播放；
         0x000002 track_in_movie，表示该track在播放中被引用；
         0x000004 track_in_preview，表示该track在预览时被引用。
         0x000008 the track is used in the movie’s poster，一般该值为7，如果一个媒体所有track均未设置track_in_movie和track_in_preview，将被理解为所有track均设置了这两项；对于hint track，该值为0
         */
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        // creation time 起始时间。基准时间是1904-1-1 0:00 AM
        index += 4
        // modification time 修订时间。基准时间是1904-1-1 0:00 AM
        index += 4
        // 唯一标志该track的一个非零值。
        let trackId = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // reserved
        index += 4
        // track的时间长度
        let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // reserved
        index += 8
        // 视频层，默认为0，值小的在上层
        let layer = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        // track分组信息，默认为0表示该track未与其他track有群组关系
        let alternateGroup = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        // [8.8] 格式，如果为音频track，1.0（0x0100）表示最大音量；否则为0
        let volume1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        let volume2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        // reserved
        index += 2
        // matrix 该矩阵定义了此track中两个坐标空间的映射关系
        index += 36
        // 图像的宽度 均为 [16.16] 格式值，与sample描述中的实际画面大小比值，用于播放时的展示宽高
        let width1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let width2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        // 图像的高度
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



func elstParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var arr = [[String: Any]]()
        for _ in 0..<Int(entryCount) {
            // duration of this edit segment in units of the movie’s time scale.
            let segmentDuration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            index += 4
            /*
             starting time within the media of this edit segment (in media
             
             timescale units)。值为-1表示是空edit。Track中的最后一个edit永远不能为空。Any difference between the movie’s duration and the track’s duration is expressed as an implicit empty edit.
             */
            let mediaTime = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            index += 4
            
            let mediaRate = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            
//            let mediaRateInteger = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
//            index += 2
//            let mediaRateFraction = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
//            index += 2
            
            arr.append(["segmentDuration": segmentDuration,
                        "mediaTime": mediaTime,
//                        "mediaRateInteger": mediaRateInteger,
//                        "mediaRateFraction": mediaRateFraction,
                        "mediaRate": mediaRate])
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
    }
    
    return dicValue
}
