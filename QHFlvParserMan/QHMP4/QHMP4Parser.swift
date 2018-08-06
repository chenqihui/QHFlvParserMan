//
//  QHMP4Parser.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/19.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 [mp4文件格式解析 - nigaopeng - 博客园](https://www.cnblogs.com/ranson7zop/p/7889272.html)
 [leslie - wqyuwss的专栏 - 52RD博客_52RD.com](http://www.52rd.com/Blog/wqyuwss/559/)
 
 [hls之m3u8、ts流格式详解 - CSDN博客](https://blog.csdn.net/guofengpu/article/details/54922865)
 */

import Cocoa

class QHMP4Parser: NSObject {
    
    static let boxSizeByteLength: Int = 4
    static let boxTypeByteLength: Int = 4
    
    let fileData: Data
    var MP4boxs: [QHMP4Box]?
    
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
    
    private func boxParser(data: Data) -> [QHMP4Box] {
        var boxs = [QHMP4Box]()
        var offset: Int = 0
        
        while offset < data.count {
            
            var box = QHMP4Box()
            box.offset = data.startIndex + offset
            
            var index = box.offset - 1
//            QHParserUtil.printHex(data: data[(index + 1)...index + 4])
            let boxSize = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: QHMP4Parser.boxSizeByteLength)
            index += QHMP4Parser.boxSizeByteLength
            
            box.header.size = Int(boxSize)
            
            let boxType = QHParserUtil.hexToString(data: data, startIndex: index, length: uint(QHMP4Parser.boxTypeByteLength))
            index += QHMP4Parser.boxTypeByteLength
            
            if let type: QHMP4BoxType = QHMP4BoxType(rawValue: boxType) {
                box.header.type = type
            }
            else {
                print("case \(boxType) = \"\(boxType)\"")
            }
            
            index += 1
            let endIndex = box.offset + Int(boxSize)
            let boxBody = data[index..<endIndex]
            offset += Int(boxSize)
            
            switch box.header.type {
            case .ftyp:
                box.dicValue = ftypParser(data: boxBody)
            case .moov, .trak, .mdia, .minf, .dinf, .stbl, .udta, .edts:
                box.boxs = boxParser(data: boxBody)
            case .mvhd:
                box.dicValue = mvhdParser(data: boxBody)
            case .tkhd:
                box.dicValue = tkhdParser(data: boxBody)
            case .mdhd:
                box.dicValue = mdhdParser(data: boxBody)
            case .hdlr:
                box.dicValue = hdlrParser(data: boxBody)
            case .vmhd:
                box.dicValue = vmhdParser(data: boxBody)
            case .smhd:
                box.dicValue = smhdParser(data: boxBody)
            case .dref:
                box.dicValue = drefParser(data: boxBody)
            case .stsd:
                box.dicValue = stsdParser(data: boxBody)
            case .stts:
                box.dicValue = sttsParser(data: boxBody)
            case .stss:
                box.dicValue = stssParser(data: boxBody)
            case .stsc:
                box.dicValue = stscParser(data: boxBody)
            case .stsz:
                box.dicValue = stszParser(data: boxBody)
            case .stco:
                box.dicValue = stcoParser(data: boxBody)
            case .meta:
                box.dicValue = metaParser(data: boxBody)
            case .elst:
                box.dicValue = elstParser(data: boxBody)
            default:
                box.body = boxBody
                break
            }
            
            boxs.append(box)
        }
        return boxs
    }
    
    func test() {
        MP4boxs = boxParser(data: fileData)
//        for box in MP4boxs! {
//            box.printBox()
//        }
    }

}
