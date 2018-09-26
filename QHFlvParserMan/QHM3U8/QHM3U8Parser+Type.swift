//
//  QHM3U8Parser+Type.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/26.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

extension QHM3U8Parser {
    func typeParser(_ m3u8Arr: [String]) -> QHBasicPlaylistType {
        var type = QHBasicPlaylistType.unknown
        var isENDLIST = false
        if let lastValue = m3u8Arr.last {
            if lastValue.hasPrefix(kEXT_X_ENDLIST) {
                isENDLIST = true
            }
        }
        for value in m3u8Arr {
            if value.hasPrefix(kEXT_X_STREAM_INF) {
                type = .master
                break
            }
            else if value.hasPrefix(kEXT_X_PLAYLIST_TYPE) {
                if value.hasSuffix("EVENT") {
                    type = .event
                }
                else { // value.hasSuffix("VOD")
                    type = .vod
                }
                break
            }
            else if value.hasPrefix(kEXTINF), isENDLIST == false {
                type = .live
            }
        }
        return type
    }
}
