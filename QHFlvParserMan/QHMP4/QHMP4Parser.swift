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
                print("undefine boxType == \(boxType)")
            }
            
            index += 1
            let endIndex = box.offset + Int(boxSize)
            let boxBody = data[index..<endIndex]
            offset += Int(boxSize)
            
            switch box.header.type {
            case .ftyp:
                ftypParser(data: boxBody)
            case .moov:
                box.boxs = boxParser(data: boxBody)
            case .trak:
                box.boxs = boxParser(data: boxBody)
            case .mdia:
                box.boxs = boxParser(data: boxBody)
            default:
                box.body = boxBody
                break
            }
            
            boxs.append(box)
        }
        return boxs
    }
    
    private func ftypParser(data: Data) {
        let length = 4
        var subIndex = data.startIndex - 1
        while subIndex < data.count {
            let value = QHParserUtil.hexToString(data: data, startIndex: subIndex, length: uint(length))
            //                    let value = QHFlvParserUtil.hexToDecimal(data: box, startIndex: index, count: 4)
            subIndex += length
            print("value == \(value)")
        }
    }
    
    private func mvhdParser(data: Data) {
    }
    
    func test() {
        MP4boxs = boxParser(data: fileData)
        for box in MP4boxs! {
            box.printBox()
        }
    }

}
