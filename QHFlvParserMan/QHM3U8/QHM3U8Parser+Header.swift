//
//  QHM3U8Parser+Header.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/26.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

extension QHM3U8Parser {
    
    func headerParser(_ m3u8Arr: [String]) -> [QHM3UTag]  {
        var headerTag = [QHM3UTag]()
        var bStartBody = false
        for value in m3u8Arr {
            if value.hasPrefix(kEXT_X_STREAM_INF) || value.hasPrefix(kEXTINF) {
                bStartBody = true
            }
            else if value.hasPrefix("#") == false, bStartBody == true {
                bStartBody = false
            }
            else if bStartBody == false, value.hasPrefix("#") == true {
                if let tag = tagParser(value) {
                    headerTag.append(tag)
                }
            }
        }
        return headerTag
    }
}
