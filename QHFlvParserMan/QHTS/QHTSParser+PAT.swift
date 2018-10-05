//
//  QHTSParser+PAT.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/6.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

extension QHTSParser {
    
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
        pat.sectionLength = v1_1 + v2
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
