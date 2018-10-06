//
//  QHTSParser+ADPAT.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/6.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

extension QHTSParser {
    
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
        
        adapt.discontinuityIndicator = Int(discontinuity_indicator)
        adapt.randomAccessIndicator = Int(random_access_indicator)
        adapt.elementaryStreamPriorityIndicator = Int(elementary_stream_priority_indicator)
        
        startIndex += 1
        if pcr_flag == 1 {
            let v1 = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: 4)
            let v1_1 = v1 << 1
            let v2 = UInt64(data[startIndex + 5])
            let v2_1 = (v2 & 0b10000000) >> 7
            let program_clock_reference_base = v1_1 + v2_1
            let v2_2 = (v2 & 0b000000001) << 8
            let v3 = UInt64(data[startIndex + 6])
            let program_clock_reference_extension = v2_2 + v3
            startIndex += 6
            
            adapt.programClockReferenceBase = program_clock_reference_base
            adapt.programClockReferenceExtension = program_clock_reference_extension
        }
        if opcr_flag == 1 {
            let v1 = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: 4)
            let v1_1 = v1 << 1
            let v2 = UInt64(data[startIndex + 5])
            let v2_1 = (v2 & 0b10000000) >> 7
            let original_program_clock_reference_base = v1_1 + v2_1
            let v2_2 = (v2 & 0b000000001) << 8
            let v3 = UInt64(data[startIndex + 6])
            let original_program_clock_reference_extension = v2_2 + v3
            startIndex += 6
            
            adapt.originalProgramClockReferenceBase = original_program_clock_reference_base
            adapt.originalProgramClockReferenceExtension = original_program_clock_reference_extension
        }
        if splicing_point_flag == 1 {
            let splice_countdown = UInt64(data[startIndex + 1])
            startIndex += 1
            
            adapt.spliceCountdown = Int(splice_countdown)
        }
        if transport_private_data_flag == 1 {
            let transport_private_data_length = UInt64(data[startIndex + 1])
            startIndex += 1
            //            for i in 0..<transport_private_data_length {
            //                  private_data_byte
            //            }
            // ???
//            startIndex += Int(transport_private_data_length)
            
            adapt.transportPrivateDataLength = transport_private_data_length
        }
        if adaptation_field_extension_flag == 1 {
            let adaptation_field_exension_length = UInt64(data[startIndex + 1])
            let v1 = UInt64(data[startIndex + 2])
            let ltw_flag = (v1 & 0b10000000) >> 7
            let piecewise_rate_flag = (v1 & 0b01000000) >> 6
            let seamless_splice_flag = (v1 & 0b00100000) >> 5
//            let reserved1 = (v1 & 0b00011111) >> 5
            startIndex += 2
            
            adapt.adaptationFieldExensionLength = adaptation_field_exension_length
            
            if ltw_flag == 1 {
                let v2 = UInt64(data[startIndex + 1])
                let ltw_valid_flag = (v2 & 0b10000000) >> 7
                let v2_1 = (v2 & 0b01111111) << 8
                let v3 = UInt64(data[startIndex + 2])
                let ltw_offset = v2_1 + v3
                startIndex += 2
                
                adapt.ltwValidFlag = Int(ltw_valid_flag)
                adapt.ltwOffset = ltw_offset
            }
            if piecewise_rate_flag == 1 {
                let v2 = UInt64(data[startIndex + 1])
                let v2_1 = (v2 & 0b00111111) << 16
                let v3 = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 1, count: 2)
                let piecewise_rate = v2_1 + v3
                startIndex += 3
                
                adapt.piecewiseRate = piecewise_rate
            }
            if seamless_splice_flag == 1 {
//                let v2 = UInt64(data[startIndex + 1])
//                for
//                let splic_type = (v2 & 0b11110000) >> 4
//                let DTS_next_AU = (v2 & 0b00001110) >> 1
//                let marker_bit = (v2 & 0b00000001)
            }
        }
        
        return adapt
    }
}
