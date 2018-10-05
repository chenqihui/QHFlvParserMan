//
//  QHTSObject.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/3.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

enum QHTSTpye {
    case none
    case PAT
    case PMT
    case ADAPT
    case NIT
}

struct QHTSObj {
    
}

struct QHTS {
    var head: QHTSHead?
    var adapt: QHTSAdaptationField?
    var pat: QHTSPAT?
    var pmt: QHTSPMT?
    var payload: QHPES?
    var type: QHTSTpye = .none
}

struct QHPES {
    var head: QHPesHead?
    var optionalHeader: Any?
    var payload: QHES?
}

struct QHES {
    var head: Any?
    var type: Any?
    var data: Any?
}

struct QHTSHead {
    var s: String = "-1"
    var ei = -1
    var pusl: Int = -1 // 在前4个字节后会有一个调整字节。所以实际数据应该为去除第一个字节后的数据。即上面数据中红色部分不属于有效数据包。
    var tpr: Int = -1
    var pid: Int = -1
    var scr = -1
    var af = -1
    var cc = -1
}

struct QHTSAdaptationField {
    var length: UInt64 = 0
    var flag: UInt64 = 0
    var pcr: Data?
    var stuffingBtyes = 255
}

struct QHTSPAT {
    var tableId = -1
    var sectionSyntaxIndicator = 1
    var zero = 0
    var reserved1 = 11
    var sectionLength: UInt64 = 0
    var transportStreamId: UInt64 = 0
    var reserved2 = 11
    var versionNumber = -1
    var currentNextIndicator = -1
    var sectionNumber = -1
    var lastSectionNumber = -1
    var programs = [QHTSPATProgram]()
    var crc32: UInt64 = 0
}

struct QHTSPATProgram {
    var programNumber = -1 // 节目号为0x0000时表示这是NIT，节目号为0x0001时,表示这是PMT
    var reserved3 = -1
    var pid = -1
}

struct QHTSPMT {
    var tableId = -1
    var sectionSyntaxIndicator = -1
    var zero = -1
    var reserved1 = -1
    var sectionLength: UInt64 = 0
    var programNumber: UInt64 = 0
    var reserved2 = -1
    var versionNumber = -1
    var currentNextIndicator = -1
    var sectionNumber = -1
    var lastSectionNumber = -1
    var reserved3 = -1
    var pcrPID: UInt64 = 0
    var reserved4 = -1
    var programInfoLength: UInt64 = 0
    var streams = [QHTSPMTStream]()
    var crc32: UInt64 = 0
}

struct QHTSPMTStream {
    var streamType = -1 // 流类型，标志是Video还是Audio还是其他数据，h.264编码对应0x1b，aac编码对应0x0f，mp3编码对应0x03
    var reserved1 = -1
    var elementaryPID = -1
    var reserved2 = -1
    var ESInfoLength = -1
}

struct QHPesHead {
    var startCode = -1 // 开始码，固定为0x000001
    var streamId = -1 // 音频取值（0xc0-0xdf），通常为0xc0 视频取值（0xe0-0xef），通常为0xe0
    var packetLength = -1 // 后面pes数据的长度，0表示长度不限制，只有视频数据长度会超过0xffff
    var flag1 = -1 // 通常取值0x80，表示数据不加密、无优先级、备份的数据
    var flag2 = -1 // 取值0x80表示只含有pts，取值0xc0表示含有pts和dts
    var dataLength = -1 // 后面数据的长度，取值5或10
    var pts: UInt64 = 0
    var dts: UInt64 = 0
}
