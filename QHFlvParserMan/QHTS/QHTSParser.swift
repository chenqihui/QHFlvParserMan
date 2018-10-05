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
    var PMTPIDs = [Int]()
    var NITPIDs = [Int]()
    
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
        var start = data.startIndex + 4
        if head.pid == 0 {
            ts.type = .PAT
            if head.pusl == 1 {
                start += 1
            }
            let pat = patParser(data, start)
            ts.pat = pat
            if let programs = ts.pat?.programs {
                for program in programs {
                    if program.programNumber == 0x0001 {
                        PMTPIDs.append(program.pid)
                    }
                    else if program.programNumber == 0x0000 {
                        NITPIDs.append(program.pid)
                    }
                }
            }
        }
        else if PMTPIDs.contains(head.pid) == true {
            ts.type = .PMT
            if head.pusl == 1 {
                start += 1
            }
            let pmt = pmtParser(data, start)
            ts.pmt = pmt
        }
        else if NITPIDs.contains(head.pid) == true {
            ts.type = .NIT
        }
        else if head.af == 0b10 || head.af == 0b11 {
            ts.type = .ADAPT
            let adapt = adaptParser(data, start)
            ts.adapt = adapt
            let preLen = start + Int(adapt.length) + 1
            let pesData = data[preLen..<data.endIndex]
            let pes = pesParser(pesData, pesData.startIndex)
            ts.payload = pes
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
        }
        
        return pmt
    }
    
    func adaptParser(_ data: Data, _ startIdx: Int) -> QHTSAdaptationField {
        var startIndex = startIdx
        var adapt = QHTSAdaptationField()
        let adaptation_field_length = UInt64(data[startIndex])
        adapt.length = adaptation_field_length
        
        let v1 = UInt64(data[startIndex + 1])
        let discontinuity_indicator = (v1 & 0b10000000) >> 7
        let random_access_indicator = (v1 & 0b01000000) >> 6
        let elementary_stream_priority_indicator = (v1 & 0b00100000) >> 5
        let pcr_flag = (v1 & 0b00010000) >> 4
        let opcr_flag = (v1 & 0b00001000) >> 3
        let splicing_point_flag = (v1 & 0b00000100) >> 2
        let transport_private_data_flag = (v1 & 0b00000010) >> 1
        let adaptation_field_extension_flag = (v1 & 0b000000001)
        
        startIndex += 2
        if pcr_flag == 1 {
            let v1 = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex - 1, count: 4)
            let v1_1 = v1 << 1
            let v2 = UInt64(data[startIndex + 6])
            let v2_1 = (v2 & 0b10000000) >> 7
            let program_clock_reference_base = v1_1 + v2_1
            let v2_2 = (v2 & 0b000000001) << 8
            let v3 = UInt64(data[startIndex + 7])
            let program_clock_reference_extension = v2_2 + v3
            startIndex += 6
        }
        if opcr_flag == 1 {
            let v1 = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex - 1, count: 4)
            let v1_1 = v1 << 1
            let v2 = UInt64(data[startIndex + 6])
            let v2_1 = (v2 & 0b10000000) >> 7
            let original_program_clock_reference_base = v1_1 + v2_1
            let v2_2 = (v2 & 0b000000001) << 8
            let v3 = UInt64(data[startIndex + 7])
            let original_program_clock_reference_extension = v2_2 + v3
            startIndex += 6
        }
        if splicing_point_flag == 1 {
            let splice_countdown = UInt64(data[startIndex])
            startIndex += 1
        }
        if transport_private_data_flag == 1 {
            let transport_private_data_length = UInt64(data[startIndex])
            startIndex += 1
//            for i in 0..<transport_private_data_length {
//                  private_data_byte
//            }
            startIndex += Int(transport_private_data_length)
        }
        if adaptation_field_extension_flag == 1 {
            let adaptation_field_exension_length = UInt64(data[startIndex])
            let v1 = UInt64(data[startIndex + 1])
            let ltw_flag = (v1 & 0b10000000) >> 7
            let piecewise_rate_flag = (v1 & 0b01000000) >> 6
            let seamless_splice_flag = (v1 & 0b00100000) >> 5
            let reserved1 = (v1 & 0b00011111) >> 5
            startIndex += 1
            if ltw_flag == 1 {
                let v2 = UInt64(data[startIndex + 1])
                let ltw_valid_flag = (v2 & 0b10000000) >> 7
                let v2_1 = (v2 & 0b01111111) << 8
                let v3 = UInt64(data[startIndex + 2])
                let ltw_offset = v2_1 + v3
                startIndex += 2
            }
            if piecewise_rate_flag == 1 {
                let v2 = UInt64(data[startIndex + 1])
                let v2_1 = (v2 & 0b00111111) << 16
                let v3 = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 1, count: 2)
                let piecewise_rate = v2_1 + v3
                startIndex += 3
            }
            if seamless_splice_flag == 1 {
                let v2 = UInt64(data[startIndex + 1])
                let splic_type = (v2 & 0b11110000) >> 4
                let DTS_next_AU = (v2 & 0b00001110) >> 1
                let marker_bit = (v2 & 0b00000001)
            }
        }
        
        return adapt
    }
    
    func pesParser(_ data: Data, _ startIdx: Int) -> QHPES {
        let startIndex = startIdx
        var pes = QHPES()
        
        var head = QHPesHead()
        let pes_start_code = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex - 1, count: 3)
        head.startCode = Int(pes_start_code)
        let stream_id = UInt64(data[startIndex + 3])
        head.streamId = Int(stream_id)
        let pes_packet_length = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 3, count: 2)
        head.packetLength = Int(pes_packet_length)
        let flag1 = UInt64(data[startIndex + 6])
        head.flag1 = Int(flag1)
        let flag2 = UInt64(data[startIndex + 7])
        head.flag2 = Int(flag2)
        let pes_data_length = UInt64(data[startIndex + 8])
        head.dataLength = Int(pes_data_length)
        let pts = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 8, count: 5)
        head.pts = pts
        let dts = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 13, count: 5)
        head.dts = dts
        
        pes.head = head
        return pes
    }
}
