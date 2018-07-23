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
                ftypParser(data: boxBody)
            case .moov, .trak, .mdia, .minf, .dinf, .stbl:
                box.boxs = boxParser(data: boxBody)
//            case .mvhd:
//                mvhdParser(data: boxBody)
//            case .tkhd:
//                tkhdParser(data: boxBody)
//            case .mdhd:
//                mdhdParser(data: boxBody)
//            case .hdlr:
//                hdlrParser(data: boxBody)
//            case .vmhd:
//                vmhdParser(data: boxBody)
//            case .smhd:
//                smhdParser(data: boxBody)
//            case .dref:
//                drefParser(data: boxBody)
            case .stsd:
                stsdParser(data: boxBody)
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
        let count = data.count / length
        var ftyp = QHMP4Ftyp()
        for index in 0..<count {
            let startIndex = data.startIndex - 1 + length * index
            if index == 1 {
                let value = QHParserUtil.hexToDecimal(data: data, startIndex: startIndex, count: length)
                ftyp.minorVersion = Int(value)
            }
            else {
                let value = QHParserUtil.hexToString(data: data, startIndex: startIndex, length: uint(length))
                if index == 0 {
                    ftyp.majorBrand = value
                }
                else {
                    ftyp.compatibleBrands.append(value)
                }
            }
        }
//        print("\(ftyp)")
    }
    
    private func mvhdParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            // creation time
            index += 4
            // modification time
            index += 4
            let timescale = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("timescale = \(timescale)")
            index += 4
            let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("duration = \(duration)")
            index += 4
            let trackTime = Double(duration)/Double(timescale)
            print("该track的时间长度：\(trackTime)")
            let rate1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            let rate2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("rate = \(rate1).\(rate2)")
            index += 2
            let volume1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
            index += 1
            let volume2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
            print("volume = \(volume1).\(volume2)")
            index += 1
            // reserved
            index += 10
            // matrix
            index += 36
            // pre-defined
            index += 24
            let nextTrackId = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("nextTrackId = \(nextTrackId)")
            index += 4
        }
    }
    
    private func tkhdParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            // creation time
            index += 4
            // modification time
            index += 4
            let trackId = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("trackId = \(trackId)")
            index += 4
            // reserved
            index += 4
            let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("duration = \(duration)")
            index += 4
            // reserved
            index += 8
            let layer = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("layer = \(layer)")
            index += 2
            let alternateGroup = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("alternateGroup = \(alternateGroup)")
            index += 2
            let volume1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
            index += 1
            let volume2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 1)
            print("volume = \(volume1).\(volume2)")
            index += 1
            // reserved
            index += 2
            // matrix
            index += 36
            let width1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            let width2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("width = \(width1).\(width2)")
            index += 2
            let height1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            let height2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("height = \(height1).\(height2)")
            index += 2
        }
    }
    
    private func mdhdParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            // creation time
            index += 4
            // modification time
            index += 4
            let timescale = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("timescale = \(timescale)")
            index += 4
            let duration = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("duration = \(duration)")
            index += 4
            let trackTime = Double(duration)/Double(timescale)
            print("该track的时间长度：\(trackTime)")
            // language
            index += 2
            // pre-defined
            index += 2
        }
    }
    
    private func hdlrParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            // pre-defined
            index += 4
            let handlerType = QHParserUtil.hexToString(data: data, startIndex: index, length: 4)
            print("handlerType = \(handlerType)")
            index += 4
            // reserved
            index += 12
            var end = uint(data[index + 1])
            var trackTypeName = ""
            while end != 0 {
                let name = QHParserUtil.hexToString(data: data, startIndex: index, length: 1)
                index += 1
                trackTypeName += name
                end = uint(data[index + 1])
            }
            print("trackTypeName = \(trackTypeName)")
        }
    }
    
    private func vmhdParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            let graphicsMode = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("graphicsMode = \(graphicsMode)")
            index += 2
            let red = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            let green = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            let blue = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            print("opcolor = {\(red), \(green), \(blue)}")
        }
    }
    
    private func smhdParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            let balance1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            index += 2
            let balance2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
            print("balance = \(balance1).\(balance2)")
            index += 2
            // reserved
            index += 2
        }
    }
    
    private func drefParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("entryCount = \(entryCount)")
            index += 4
            for _ in 0..<Int(entryCount) {
                let size = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
                let type = QHParserUtil.hexToString(data: data, startIndex: index + 4, length: 4)
                let flag = QHParserUtil.hexToDecimal(data: data, startIndex: index + 8, count: 4)
                print("size = \(size), type = \(type), flag = \(flag)")
                if flag == 1 {
                    // 说明“url”中的字符串为空，表示track数据已包含在文件中
                }
                index += Int(size)
            }
        }
    }
    
    private func stsdParser(data: Data) {
        var index = data.startIndex
        let version = uint(data[index])
        print("version = \(version)")
        if version == 0 {
            let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
            print("flags = \(flags)")
            index += 3
            let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            print("entryCount = \(entryCount)")
            index += 4
            for _ in 0..<Int(entryCount) {
                let size = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
                let type = QHParserUtil.hexToString(data: data, startIndex: index + 4, length: 4)
                print("size = \(size), type = \(type)")
                index += Int(size)
            }
        }
    }
    
    func test() {
        MP4boxs = boxParser(data: fileData)
//        for box in MP4boxs! {
//            box.printBox()
//        }
    }

}
