//
//  QHMP4Object.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/20.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Foundation

struct QHMP4Box {
    var offset: Int = 0
    var header = QHMP4BoxHeader()
    var body: Data?
    var boxs: [QHMP4Box]?
    
    func printBox() {
        print("offset = \(offset)")
        print("header.size = \(header.size)")
        print("header.type = \(header.type)")
        
        if let boxsT = boxs {
            print("{")
            for box in boxsT {
                box.printBox()
            }
            print("}")
        }
    }
}

struct QHMP4BoxHeader {
    var size: Int = 0
    var type: QHMP4BoxType = .none
}

/*
 - ftyp
 - free
 - mdat
 - moov
    - mvhd
    - trak
        - tkhd
        - edts
            - mdia
                - mdhd
                - hdlr
                - minf
    - trak
    - udta
 */
enum QHMP4BoxType: String {
    case none = "none"
    case ftyp = "ftyp"
    case free = "free"
    case mdat = "mdat"
    case moov = "moov"
    case mvhd = "mvhd"
    case trak = "trak"
    case tkhd = "tkhd"
    case edts = "edts"
    case mdia = "mdia"
    case udta = "udta"
}
