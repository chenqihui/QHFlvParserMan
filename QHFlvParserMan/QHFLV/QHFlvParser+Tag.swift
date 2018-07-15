//
//  QHFlvParser+Tag.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

//QHFlvBody
/*
 2、FLV File Body - 由一连串的PreviousTagSize + Tag构成。previousTagSize是4个字节的数据，表示前一个tag的size。
 */
extension QHFlvParser {
    //2.1、PreviousTagSize的长度为4个字节，用来表示前一个Tag的长度
    func previousTagSize(startIndex: Int) -> uint {
        if fileData.count > uint(startIndex) + QHFlvParser.previousTagSizeBytes {
            let size = QHFlvParserUtil.hexToDecimal(data: fileData, startIndex: startIndex, count: 4)
            
            return uint(size)
        }
        return 0
    }
    
    //2.2、Tag里面的数据可能是video、audio或者scripts
    func tag(startIndex: Int) -> QHFlvTag {
        var index = startIndex
        var tag = QHFlvTag()
        if fileData.count > uint(index) + QHFlvParser.tagSizeBytesExceptHeaderAndBody {
            index += 1
            let v1 = uint(fileData[index])
            //2.2.1、0x08, 二进制为0000 1000，第5位为0, 表示为非加扰文件;
            if v1 & 0b00100000 == 0b00100000 {
                //加扰文件
                tag.signature = true
            }
            else {
                //非加扰文件
                tag.signature = false
            }
            //2.2.2、低5位01000为8，说明这个Tag包含的数据类型为Audio；
            let v1_2 = v1 & 0b00011111
            if v1_2 == 8 {
                tag.tagType = .audio
            }
            else if v1_2 == 9 {
                tag.tagType = .video
            }
            else if v1_2 == 18 {
                /*
                 2.2.3
                 [3.5 Script Data Tags]
                 如果TAG包中的TagType等于18，表示该Tag中包含的数据类型为SCRIPT。
                 
                 SCRIPTDATA 结构十分复杂，定义了很多格式类型，每个类型对应一种结构
                 
                 [E.5 onMetaData]是SCRIPTDATA中一个非常重要的信息，其结构定义可参考E.5 onMetaData。它通常是FLV文件中的第一个Tag，用来表示当前文件的一些基本信息: 比如视音频的编码类型id、视频的宽和高、文件大小、视频长度、创建日期等。
                 */
                tag.tagType = .script
            }
            //2.2.4、Tag的内容长度为，与该tag后面的previousTagSize() - 11相同；
            var number = QHFlvParserUtil.hexToDecimal(data: fileData, startIndex: index, count: 3)
            tag.dataSize = uint(number)
            index += 3
            
            //2.2.5、当前Audio数据的时间戳；
            number = QHFlvParserUtil.hexToDecimal(data: fileData, startIndex: index, count: 3)
            tag.timestamp = uint(number)
            index += 3
            
            //2.2.6、扩展时间戳，如果扩展时间戳不为0，那么该Tag的时间戳应为：Timestamp | TimestampExtended<<24；
            number = QHFlvParserUtil.hexToDecimal(data: fileData, startIndex: index, count: 1)
            tag.timestampExtended = uint(number)
            index += 1
            
            //2.2.7、StreamID
            number = QHFlvParserUtil.hexToDecimal(data: fileData, startIndex: index, count: 3)
            tag.streamID = uint(number)
            index += 3
            
            //2.2.8、解析音视频数据
            index += 1
            let startIndex = uint(index)
            let endIndex = startIndex + tag.dataSize
            let data = fileData[startIndex..<endIndex]
            
            if tag.tagType == .script {
                var index = data.startIndex
                while index < data.endIndex {
                    index = script(data, startIndex: index)
                    index += 1
                }
            }
            else if tag.tagType == .video {
                tag.tagBody = video(data)
            }
            else if tag.tagType == .audio {
                tag.tagBody = audio(data)
            }
        }
        return tag
    }
}
