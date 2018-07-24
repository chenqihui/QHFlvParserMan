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
    var dicValue: [String: Any]?
    
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

struct QHMP4Ftyp {
    var majorBrand: String = ""
    var minorVersion: Int = 0
    var compatibleBrands = [String]()
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
    // moov sub
    case mvhd = "mvhd"
    case trak = "trak"
    case udta = "udta"
    //
    // trak sub
    case tkhd = "tkhd"
    case edts = "edts"
    case mdia = "mdia"
    //
    // mdia sub
    case mdhd = "mdhd"
    case hdlr = "hdlr"
    case minf = "minf"
    //
    // minf sub
    case vmhd = "vmhd"
    case smhd = "smhd"
    case dinf = "dinf"
    case stbl = "stbl"
    //
    // dinf sub
    case dref = "dref"
    //
    // stbl sub
    case stsd = "stsd"
    case stts = "stts"
    case stss = "stss"
    case ctts = "ctts"
    case stsc = "stsc"
    case stsz = "stsz"
    case stco = "stco"
    case sgpd = "sgpd"
    case sbgp = "sbgp"
    //
}
