//
//  QHTSParser+PES.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/6.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

extension QHTSParser {
    
    func pesParser(_ data: Data, _ startIdx: Int) -> QHPES {
        let startIndex = startIdx
        var pes = QHPES()
        
        if data.count < 19 {
            return pes
        }
        
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
        if head.flag2 == 0x80 || head.flag2 == 0xc0 {
            let pts = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 8, count: 5)
            head.pts = pts
            if head.flag2 == 0xc0 {
                let dts = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex + 13, count: 5)
                head.dts = dts
            }
        }
        
        pes.head = head
        return pes
    }
}
