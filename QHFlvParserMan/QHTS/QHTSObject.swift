//
//  QHTSObject.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/3.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

struct QHTSObj {
    
}

struct QHTS {
    var head: QHTSHead?
    var adapt: QHTSAdaptationField?
    var pat: QHTSPAT?
    var pmt: QHSTPMT?
    var payload: QHPES?
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
    var programNumber = -1// 节目号为0x0000时表示这是NIT，节目号为0x0001时,表示这是PMT
    var reserved3 = -1
    var pid = -1
}

struct QHSTPMT {
    var tableId = -1
    var sectionSyntaxIndicator = -1
    var zero = -1
    var reserved1 = -1
    var sectionLength = -1
    var programNumber = -1
    var reserved2 = -1
    var versionNumber = -1
    var currentNextIndicator = -1
    var sectionNumber = -1
    var lastSectionNumber = -1
    var reserved3 = -1
    var pcr_pid = -1
    var reserved4 = -1
    var programInfoLength = -1
    var startLoop = -1
    var elementaryPID = -1
    var reserved5 = -1
    var ESInfoLength = -1
    var endLoop = -1
    var crc32 = -1
}

struct QHPesHead {
    var startCode = -1
    var streamId = -1
    var packetLength = -1
    var flag1 = -1
    var flag2 = -1
    var dataLength = -1
    var pts = -1
    var dts = -1
}
