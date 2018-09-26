//
//  QHM3U8Parser+Body.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/26.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

extension QHM3U8Parser {
    
    func bodyParser(_ path: String, _ m3u8Arr: [String]) -> [QHM3UBody] {
        var bodyArr = [QHM3UBody]()
        var body: QHM3UBody?
        var bStartBody = false
        for value in m3u8Arr {
            if value.hasPrefix(kEXT_X_STREAM_INF) || value.hasPrefix(kEXTINF) {
                bStartBody = true
                body = QHM3UBody()
                if let tag = tagParser(value) {
                    body?.tag.append(tag)
                }
            }
            else if value.hasPrefix("#") == false, bStartBody == true {
                bStartBody = false
                body?.url = value
                if let b = body {
                    bodyArr.append(b)
                }
            }
            else if bStartBody == true, value.hasPrefix("#") == true {
                if let tag = tagParser(value) {
                    body?.tag.append(tag)
                }
            }
        }
        return bodyArr
    }
}
