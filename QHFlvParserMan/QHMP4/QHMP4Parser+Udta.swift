//
//  QHMP4Parser+Udta.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 udta
 
 1.meta
 */

import Cocoa

extension QHMP4Parser {
    
    func metaParser(data: Data) -> [String: Any] {
        
        var dicValue = [String: Any]()
        
        var index = data.startIndex
        let version = uint(data[index])
        dicValue["version"] = version
        
        if version == 0 {
//            let handlerBox = QHParserUtil.hexToString(data: data, startIndex: index, length: 4)
//            dicValue["handlerBox"] = handlerBox
//            index += 4
        }
        
        return dicValue
    }
}
