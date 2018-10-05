//
//  QHM3U8Object.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/25.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

enum QHBasicPlaylistType {
    case unknown
    case vod
    case live
    case event
    case master
}


public let kM3U8 = "M3U8"
public let kEXTM3U = "#EXTM3U"
public let kEXT_X_STREAM_INF = "#EXT-X-STREAM-INF"
public let kEXTINF = "#EXTINF"
public let kEXT_X_ENDLIST = "#EXT-X-ENDLIST"
public let kEXT_X_PLAYLIST_TYPE = "#EXT-X-PLAYLIST-TYPE"
public let kEXT_X_I_FRAME_STREAM_INF = "#EXT-X-I-FRAME-STREAM-INF"

public let kPROGRAM_ID = "PROGRAM-ID"
public let kBANDWIDTH = "BANDWIDTH"

struct QHM3UObj {
    var path: String!
    var relativePath: URL?
    var type = QHBasicPlaylistType.unknown
    var headerTag = [QHM3UTag]()
    var bodyArr = [QHM3UBody]()
    var subM3UObj: [QHM3UObj]? // First
    
    init(path p: String) {
        path = p
        if let url = URL(string: path) {
            relativePath = url.deletingLastPathComponent()
        }
    }
}

struct QHM3UBody {
    var tag = [QHM3UTag]()
    var url: String?
    
    private var pIsAP = -1
    var isAP: Bool {
        mutating get {
            if pIsAP == 0 {
                return false
            }
            else if pIsAP == 1 {
                return true
            }
            else {
                if let u = url {
                    if u.lowercased().hasPrefix("http:") == false, u.lowercased().hasPrefix("https:") == false {
                        pIsAP = 0
                        return false
                    }
                    else {
                        pIsAP = 1
                        return true
                    }
                }
                return true
            }
        }
    }
}

struct QHM3UTag {
    var tag: String!
    var value = [QHM3UTagProperty]()
    
    init(tag t: String) {
        tag = t
    }
}

struct QHM3UTagProperty {
    var key: String?
    var value: Any?
}
