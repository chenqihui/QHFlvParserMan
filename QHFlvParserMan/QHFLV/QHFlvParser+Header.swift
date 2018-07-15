//
//  QHFlvParser+Header.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

//QHFlvHeader
/*
 1、FLV Header：位置0x00000000 - 0x00000008, 共9个字节，为FLV Header
 */
extension QHFlvParser {
    
    //1.1、0x00000000 - 0x00000002 : 0x46 0x4C 0x56分别表示字符'F''L''V'，用来标识这个文件是FLV格式的。在做格式探测的时候，如果发现前3个字节为“FLV”，就认为它是FLV文件；
    func isFlvFile() -> Bool {
        if fileData.count > 3 {
            let v0 = String(fileData[0], radix: 16)
            let v1 = String(fileData[1], radix: 16)
            let v2 = String(fileData[2], radix: 16)
            if v0 == "46" && v1.uppercased() == "4C" && v2 == "56" {
                return true
            }
        }
        return false
    }
    
    //1.2、0x00000003 : 0x01, 表示FLV版本号；
    func version() -> uint {
        if fileData.count > 4 {
            return uint(fileData[3])
        }
        return 0
    }
    
    //1.3、0x00000004 : 0x05, 转换为2进制是0000 0101，其中第0位为1，表示存在video，第2位为1，表示存在audio；
    func type() -> QHFlvType {
        if fileData.count > 5 {
            let v4 = uint(fileData[4])
            if v4 & 0b00000001 == 0b00000001 && v4 & 0b00000100 == 0b00000100 {
                return .videoAndAudio
            }
            else if v4 & 0b00000001 == 0b00000001 {
                return .videoOnly
            }
            else if v4 & 0b00000100 == 0b00000100 {
                return .audioOnly
            }
        }
        return .none
    }
    
    //1.4、0x00000005 - 0x00000008 : 0x00 0x00 0x00 0x09，转十进制为9，表示FLV header的长度，当FLV 版本号为1时，该值通常为9。
    func headerLength() -> uint {
        if fileData.count > 9 {
            let length = QHFlvParserUtil.hexToDecimal(data: fileData, startIndex: 4, count: 4)
            return uint(length)
        }
        return 0
    }
}
