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
 定义了整个movie的特性，例如time scale和duration
 2.trak
    container box
 一个Track atom定义了movie中的一个track。一部movie可以包含一个或多个tracks，它们之间相互独立，各自有各自的时间和空间信息。每个track atom 都有与之关联的media atom。
 其子box包含了该track的媒体数据引用和描述（hint track除外）。一个MP4文件中的媒体可以包含多个track，且至少有一个track，这些track之间彼此独立，有自己的时间和空间信息。“trak”必须包含一个“tkhd”和一个“mdia”，此外还有很多可选的box（略）。其中“tkhd”为track header box，“mdia”为media box，该box是一个包含一些track媒体数据信息box的container box。
 3.udta
    container box
 用户数据atom('udta')
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
        // creation time 起始时间。基准时间是1904-1-1 0:00 AM
        index += 4
        // modification time 修订时间。基准时间是1904-1-1 0:00 AM
        index += 4
        // time scale相当于定义了标准的1秒在这部视频里面的刻度是多少，可以理解为1秒长度的时间单元数
        let timescale = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        // 整个视频的长度
        let mediaDuration = Double(duration)/Double(timescale)
        // 推荐播放速率，高16位和低16位分别为小数点整数部分和小数部分，即[16.16] 格式，该值为1.0（0x00010000）表示正常前向播放
        let rate1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let rate2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        // 与rate类似，[8.8] 格式，1.0（0x0100）表示最大音量
        let volume1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        let volume2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
        index += 1
        // reserved
        index += 10
        // matrix 视频变换矩阵:该矩阵定义了此movie中两个坐标空间的映射关系
        index += 36
        // pre-defined
        index += 24
        // 下一个待添加track的ID值。0不是一个有效的ID值。
        let nextTrackId = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        dicValue["flags"] = flags
        dicValue["timescale"] = timescale
        dicValue["duration"] = duration
        dicValue["mediaDuration"] = mediaDuration
        dicValue["rate"] = "\(rate1).\(rate2)"
        dicValue["volume"] = "\(volume1).\(volume2)"
        dicValue["nextTrackId"] = nextTrackId
    }
    return dicValue
}
