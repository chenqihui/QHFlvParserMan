//
//  QHTSParser+PMT.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/6.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

extension QHTSParser {
    
    func pmtParser(_ data: Data, _ startIdx: Int) -> QHTSPMT {
        var startIndex = startIdx
        var pmt = QHTSPMT()
        let table_id = UInt64(data[startIndex])
        pmt.tableId = Int(table_id)
        let v1 = UInt64(data[startIndex + 1])
        let section_syntax_indicator = v1 >> 7
        pmt.sectionSyntaxIndicator = Int(section_syntax_indicator)
        let zero = v1 >> 6 & 0x1
        pmt.zero = Int(zero)
        let reserved_1 = v1 >> 4 & 0x3
        pmt.reserved1 = Int(reserved_1)
        let v1_1 = (v1 & 0x0F) << 8
        let v2 = UInt64(data[startIndex + 2])
        pmt.sectionLength = v1_1 + v2
        startIndex += 4
        let transport_stream_id = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: 2)
        pmt.programNumber = transport_stream_id
        startIndex += 3
        let v3 = UInt64(data[startIndex])
        let version_number = (v3 & 0b01111100) >> 2
        pmt.versionNumber = Int(version_number)
        let current_next_indicator = v3 & 0b00000001
        pmt.currentNextIndicator = Int(current_next_indicator)
        let section_number = UInt64(data[startIndex + 1])
        pmt.sectionNumber = Int(section_number)
        let last_section_number = UInt64(data[startIndex + 2])
        pmt.lastSectionNumber = Int(last_section_number)
        let v4 = UInt64(data[startIndex + 3])
        let v4_1 = (v4 & 0x1F) << 8
        let v5 = UInt64(data[startIndex + 4])
        pmt.pcrPID = v4_1 + v5
        let v6 = UInt64(data[startIndex + 5])
        let v6_1 = (v6 & 0x0F) << 8
        let v7 = UInt64(data[startIndex + 6])
        pmt.programInfoLength = v6_1 + v7
        
        let len = Int(pmt.sectionLength + 3)
        let CRC32 = QHParserUtil.hexToDecimal(data: data, startIndex: (startIdx - 1 + len - 4), count: 4)
        pmt.crc32 = CRC32
        
        for sIdx in stride(from: (startIdx + 12), to: (startIdx + 12 + len - 16) , by: 5) {
            var stream = QHTSPMTStream()
            let stream_type = UInt64(data[sIdx])
            stream.streamType = Int(stream_type)
            let v1 = UInt64(data[sIdx + 1])
            let v1_1 = (v1 & 0x1F) << 8
            let v2 = UInt64(data[sIdx + 2])
            stream.elementaryPID = Int(v1_1 + v2)
            let v3 = UInt64(data[sIdx + 2])
            let v3_1 = (v3 & 0b00001111) << 8
            let v4 = UInt64(data[sIdx + 3])
            stream.ESInfoLength = Int(v3_1 + v4)
            pmt.streams.append(stream)
            
            if stream_type == 0x1b { // h.264
                h264PIDs.append(stream.elementaryPID)
            }
            else if stream_type == 0x0f { // aac
                ACCPIDs.append(stream.elementaryPID)
            }
            else if stream_type == 0x03 { // mp3
                MP3PIDs.append(stream.elementaryPID)
            }
        }
        
        return pmt
    }
}
