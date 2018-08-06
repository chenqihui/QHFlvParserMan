//
//  QHMP4Parser+Dinf.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 dinf
 
 1.dref
 */

import Cocoa

func drefParser(data: Data) -> [String: Any] {
    
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
            let size = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            /*
             类型  描述
             alis Data reference是一个Macintosh alias。一个alias包含文件信息，例如全路径名。
             rsrc Data reference是一个Macintosh alias。Alias末尾是文件使用的资源类型（32bit整数）和ID（16bit带符号的整数）
             url 一个C类型的字符串，表示一个URL。字符串后可以有其他的数据。
             */
            let type = QHParserUtil.hexToString(data: data, startIndex: index + 4, length: 4)
            let flag = QHParserUtil.hexToDecimal(data: data, startIndex: index + 8, count: 4)
            
            arr.append(["size": size,
                        "type": type,
                        "flag": flag])
            
            if flag == 1 {
                // 说明“url”中的字符串为空，表示track数据已包含在文件中
            }
            index += Int(size)
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
    }
    return dicValue
}
