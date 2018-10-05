//
//  QHTSParser.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/3.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHTSParser: NSObject {
    
    let tsLength = 188
    let fileData: Data
    
    init(path: String) {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            self.fileData = try Data(contentsOf: fileUrl)
        } catch  {
            self.fileData = Data()
            print("读取文件错误")
            print(error)
        }
    }
    
    func parser() {
        var offset: Int = 0
        var tsArr = [QHTS]()
        while offset < fileData.count {
            let endOffSet = offset + tsLength
            let tsData = fileData[offset..<endOffSet]
            let ts = tsPaser(data: tsData)
            tsArr.append(ts)
            offset = endOffSet
        }
    }
    
    func tsPaser(data: Data) -> QHTS {
        var ts = QHTS()
        let head = tsHeadParser(data, data.startIndex)
        ts.head = head
        if head.af == 0b10 || head.af == 0b11 {
            ts.adapt = adaptParser(data, data.startIndex + 4)
        }
        else if head.pid == 0 {
            var start = data.startIndex + 4
            if head.pusl == 1 {
                start += 1
            }
            ts.pat = patParser(data, start)
        }
        else {
            
        }
        return ts
    }
    
    func tsHeadParser(_ data: Data, _ startIdx: Int) -> QHTSHead {
        let startIndex = startIdx
        var head = QHTSHead()
        let sync_byte = String(data[startIndex], radix: 16) // 47
        head.s = sync_byte
        let v1 = UInt64(data[startIndex + 1])
        let transport_error_indicator = (v1 & 0b10000000) >> 7
        head.ei = Int(transport_error_indicator)
        let payload_unit_start_indicator = (v1 & 0b01000000) >> 6
        head.pusl = Int(payload_unit_start_indicator)
        let transport_priority = (v1 & 0b00100000) >> 5
        head.tpr = Int(transport_priority)
        let v1_1 = v1 & 0x1f
        let v1_1_1 = v1_1 * 1<<8
        let v2 = UInt64(data[startIndex + 2])
        head.pid = Int(v1_1_1 + v2)
        let v3 = UInt64(data[startIndex + 3])
        let transport_scrambling_control = (v3 & 0b11000000) >> 6
        head.scr = Int(transport_scrambling_control)
        let adaptation_field_control = (v3 & 0b00110000) >> 4
        head.af = Int(adaptation_field_control)
        let continuity_counter = v3 & 0b00001111
        head.cc = Int(continuity_counter)
        return head
    }
    
    func adaptParser(_ data: Data, _ startIdx: Int) -> QHTSAdaptationField {
        let startIndex = startIdx
        var adapt = QHTSAdaptationField()
        let adaptation_field_length = UInt64(data[startIndex])
        adapt.length = adaptation_field_length
        let flag = UInt64(data[startIndex + 1])
        adapt.flag = flag
        if adapt.flag == UInt64(0x50) {
            let s = startIndex + 2
            adapt.pcr = data[s..<(s + 5)]
        }
        return adapt
    }
    
    func patParser(_ data: Data, _ startIdx: Int) -> QHTSPAT {
        var startIndex = startIdx
        var pat = QHTSPAT()
        let table_id = UInt64(data[startIndex])
        pat.tableId = Int(table_id)
        let v1 = UInt64(data[startIndex + 1])
        let section_syntax_indicator = v1 >> 7
        pat.sectionSyntaxIndicator = Int(section_syntax_indicator)
        let zero = v1 >> 6 & 0x1
        pat.zero = Int(zero)
        let reserved_1 = v1 >> 4 & 0x3
        pat.reserved1 = Int(reserved_1)
        let v1_1 = (v1 & 0x0F) << 8
        let v2 = UInt64(data[startIndex + 2])
        pat.sectionLength = v1_1 | v2
        startIndex += 4
        let transport_stream_id = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: 2)
        pat.transportStreamId = transport_stream_id
        startIndex += 3
        let v3 = UInt64(data[startIndex])
        let version_number = (v3 & 0b01111100) >> 2
        pat.versionNumber = Int(version_number)
        let current_next_indicator = v3 & 0b00000001
        pat.currentNextIndicator = Int(current_next_indicator)
        let section_number = UInt64(data[startIndex + 1])
        pat.sectionNumber = Int(section_number)
        let last_section_number = UInt64(data[startIndex + 2])
        pat.lastSectionNumber = Int(last_section_number)
        
        let len = Int(pat.sectionLength + 3)
        let CRC32 = QHParserUtil.hexToDecimal(data: data, startIndex: (startIdx - 1 + len - 4), count: 4)
        pat.crc32 = CRC32
        
        for sIdx in stride(from: (startIdx + 8), to: (startIdx + 8 + len - 12) , by: 4) {
            var program = QHTSPATProgram()
            let program_number = QHParserUtil.hexToDecimal(data: data, startIndex: sIdx - 1, count: 2)
            program.programNumber = Int(program_number)
            let v1 = UInt64(data[sIdx + 2])
            let v1_1 = v1 & 0b00011111
            let v1_1_1 = v1_1 * 1<<8
            let v2 = UInt64(data[sIdx + 3])
            program.pid = Int(v1_1_1 + v2)
            pat.programs.append(program)
        }
        
        return pat
    }
}
