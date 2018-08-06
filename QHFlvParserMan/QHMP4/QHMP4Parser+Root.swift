//
//  QHMP4Parser+Root.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

/*
 root:
 
 1.ftyp
 该box有且只有1个，并且只能被包含在文件层，而不能被其他box包含。该box应该被放在文件的最开始，指示该MP4文件应用的相关信息。
 
 “ftyp” body依次包括1个32位的major brand（4个字符），1个32位的minor version（整数）和1个以32位（4个字符）为单位元素的数组compatible brands。
 2.moov
    container box
 该box包含了文件媒体的metadata信息，“moov”是一个container box，具体内容信息由子box诠释。同File Type Box一样，该box有且只有一个，且只被包含在文件层。一般情况下，“moov”会紧随“ftyp”出现。“moov”中会包含1个“mvhd”和若干个“trak”
 是一个容器atom，至少必须包含三种atom中的一种—movie header atom('mvhd'), compressed movie atom('cmov')和reference movie atom ('rmra')。没有压缩的 movie header atom必须至少包含movie header atom 和reference movie atom中的一种。
 主要包含三个子atom，movie header atom(mvhd), 一个audio track atom(trak)，一个video track atom(trak)。
 3.free
    ignore
 Free Space Box（free或skip）
 “free”中的内容是无关紧要的，可以被忽略。该box被删除后，不会对播放产生任何影响。
 4.mdat
 该box包含于文件层，可以有多个，也可以没有（当媒体数据全部为外部文件引用时），用来存储媒体数据。数据直接跟在box type字段后面，具体数据结构的意义需要参考metadata（主要在sample table中描述）。
 */

extension QHMP4Parser {
    
    func ftypParser(data: Data) -> [String: Any] {
        
        var dicValue = [String: Any]()
        
        let length = 4
        let count = data.count / length
        for index in 0..<count {
            let startIndex = data.startIndex - 1 + length * index
            if index == 1 {
                let value = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: length)
                dicValue["minorVersion"] = value
            }
            else {
                let value = QHParserUtil.hexToString(data: data, startIndex: startIndex, length: uint(length))
                if index == 0 {
                    dicValue["majorBrand"] = value
                }
                else {
                    if var arr = dicValue["compatibleBrands"] as? [Any] {
                        arr.append(value)
                        dicValue["compatibleBrands"] = arr
                    }
                    else {
                        let arr = [value]
                        dicValue["compatibleBrands"] = arr
                    }
                }
            }
        }
        return dicValue
    }
}
