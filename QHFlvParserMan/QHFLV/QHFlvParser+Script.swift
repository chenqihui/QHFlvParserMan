//
//  QHFlvParser+Script.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

extension QHFlvParser {
    
    func script(_ data: Data, startIndex: Int) -> Int {
        var index = startIndex
        let v1 = uint(data[index])
        
        if v1 == 0 {
            let v2 = uint(data[index + 1])
            if v2 == 0 {
                let v3 = uint(data[index + 2])
                if v3 == 9 {
                    return data.endIndex;
                }
            }
        }
        
        switch v1 {
        case 0:
            let number = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            index += 4
            print("\(number)")
        case 1:
            index += 1
            let v1 = uint(data[index])
            print("\(v1)")
        case 2:
            let length = uint(QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2))
            index += 2
            let value = QHParserUtil.hexToString(data: data, startIndex: index, length: length)
            index += Int(length)
            print("\(value) = ")
        case 8:
            let count = Int(QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4))
            index += 4
            for _ in 0..<count {
                index = scriptArrayPaser(data, startIndex: index)
            }
        default:
            print("")
        }
        
        return index
    }
    
    private func scriptArrayPaser(_ data: Data, startIndex: Int) -> Int {
        var index = startIndex
        let length = uint(QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2))
        index += 2
        let keyValue = QHParserUtil.hexToString(data: data, startIndex: index, length: length)
        index += Int(length)
        
        index += 1
        let valueType = uint(data[index])
        
        switch valueType {
        case 0:
            let number = QHParserUtil.hexToDouble(data: data, startIndex: index, count: 8)
            index += 8
            onMetaDataDic[keyValue] = number
        case 1:
            index += 1
            let v1 = uint(data[index])
            let bResult = v1 != 0 ? "YES" : "NO"
            onMetaDataDic[keyValue] = bResult
        case 2:
            let length = uint(QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2))
            index += 2
            let value = QHParserUtil.hexToString(data: data, startIndex: index, length: length)
            index += Int(length)
            onMetaDataDic[keyValue] = value
        default:
            onMetaDataDic[keyValue] = ""
        }
        
        return index
    }
}
