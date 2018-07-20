//
//  QHFlvParser+Video.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

extension QHFlvParser {

    //4、video data
    func video(_ data: Data) -> QHVideoTag {
        var index = data.startIndex
        var tag = QHVideoTag()
        let v1 = uint(data[index])
        //4.1、高4位为0001，转十进制为1，表示当前帧为关键帧；
        let v1_1 = v1 & 0b11110000
        if v1_1>>4 == 1 {
            tag.frameType = 1
        }
        //4.2、低4位为0111，转十进制为7，说明当前视频的编码格式为AVC
        let v1_2 = v1 & 0b00001111
        tag.codecID = v1_2//7为AVC
        //4.3、十进制为0，并且Video的编码格式为AVC，说明VideoTagBody中存放的是AVC sequence header
        index += 1
        let v2 = uint(data[index])
        
        //4.4、AVCPacketType 表示接下来 VIDEODATA （AVCVIDEOPACKET）的内容
        tag.avcPackType = v2
        if v2 == 0 {
            //AVCDecoderConfigurationRecord（AVC sequence header）
        }
        else if v2 == 1 {
            //One or more NALUs (Full frames are required)
        }
        
        //4.5、CompositonTime相对时间戳，如果AVCPacketType=0x01，为相对时间戳，其它均为0；
        let number = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        tag.compositionTime = uint(number)
        index += 3
        
        //4.6、VIDEODATA数据，即AVC sequence header
        index += 1
        tag.videoBody = data[index..<data.endIndex]
        
        return tag
    }
}
