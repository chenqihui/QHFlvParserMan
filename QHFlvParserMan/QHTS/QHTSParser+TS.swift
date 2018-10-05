//
//  QHTSParser+TS.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/6.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

extension QHTSParser {
    
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
//            if head.pusl == 1 {
//                start += 1
//            }
            let adapt = adaptParser(data, start)
            ts.adapt = adapt
            let preLen = start + Int(adapt.length) + 1
            let pesData = data[preLen..<data.endIndex]
            let pes = pesParser(pesData, pesData.startIndex)
            ts.payload = pes
        }
        
        return ts
    }
}

extension QHTSParser {
    
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
}
