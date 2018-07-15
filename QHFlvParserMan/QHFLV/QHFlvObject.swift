//
//  QHFlvObject.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/6/17.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

enum QHFlvType {
    case none
    case videoAndAudio
    case videoOnly
    case audioOnly
}

enum QHFlvTagType {
    case none
    case header
    case script
    case video
    case audio
}

struct QHFlvBody {
    let id: uint
    var offset: uint
    var format: String {
        get {
            if tag.tagType == .audio, let audiobody = tag.tagBody as? QHAudioTag {
                if audiobody.soundFormat == 10 {
                    return "AAC"
                }
            }
            else if tag.tagType == .video, let videobody = tag.tagBody as? QHVideoTag {
                if videobody.codecID == 7 {
                    return "AVC"
                }
            }
            return "n/a"
        }
    }
    var ext: String?
    var tag: QHFlvTag
    var previousTagSize: uint
    
    init(id: uint, tag: QHFlvTag) {
        self.id = id
        self.tag = tag
        offset = 0
        previousTagSize = 0
    }
}

struct QHFlvTag {
    var signature: Bool
    var filter: uint
    var tagType: QHFlvTagType
    var dataSize: uint
    var timestamp: uint
    var timestampExtended: uint
    var streamID: uint
    var tagBody: Any?
    
    init() {
        signature = false
        filter = 0
        tagType = .none
        dataSize = 0
        timestamp = 0
        timestampExtended = 0
        streamID = 0
    }
}

struct QHAudioTag {
    var soundFormat: uint
    var soundRate: String?
    var soundSize: String?
    var soundType: String?
    var aacPackType: uint
    var audioBody: Any
    
    init() {
        soundFormat = 0
        aacPackType = 0
        audioBody = 0
    }
}

struct QHVideoTag {
    var frameType: uint//1为关键帧
    var codecID: uint
    var avcPackType: uint
    var compositionTime: uint
    var videoBody: Any
    
    init() {
        frameType = 0
        codecID = 0
        avcPackType = 0
        compositionTime = 0
        videoBody = 0
    }
}
