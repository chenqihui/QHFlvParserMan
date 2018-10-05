//
//  QHFlvParser.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/15.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHFlvParser: NSObject {
    
    static let previousTagSizeBytes: uint = 4
    static let tagSizeBytesExceptHeaderAndBody: uint = 11
    
    let fileData: Data
    var flvBodys = [QHFlvBody]()
    var onMetaDataDic = [String: Any]()
    
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
    
    func test() {
        if isFlvFile() {
            print("是 flv 文件")
            print("版本：\(version())")
            print("类型：\(type())")
            print("头部长度：\(headerLength())")
            
            let _ = fileParser()
        }
        else {
            print("不是 flv 文件")
        }
    }
    
    func fileParser() -> Bool {
        if isFlvFile() {
            var flvOffset: uint = 0
            var flvTag = QHFlvTag()
            flvTag.tagType = .header
            flvTag.dataSize = headerLength()
            var flvBody = QHFlvBody(id: 0, tag: flvTag)
            flvBody.offset = flvOffset
            flvBodys.append(flvBody)
            
            flvOffset += flvTag.dataSize - 1 //偏移值，从 0 开始
            
            var id: uint = 1
            while flvOffset < fileData.count {
                let previousTagSizeTemp = previousTagSize(startIndex: Int(flvOffset))
                flvOffset += QHFlvParser.previousTagSizeBytes
                
                flvTag = tag(startIndex: Int(flvOffset))
                flvBody.previousTagSize = previousTagSizeTemp
                flvBody.tag = flvTag
                flvBody = QHFlvBody(id: id, tag: flvTag)
                flvBody.offset = (flvOffset - QHFlvParser.previousTagSizeBytes)
                flvBodys.append(flvBody)
                
                flvOffset += flvBody.tag.dataSize + QHFlvParser.tagSizeBytesExceptHeaderAndBody
                id += 1
            }
            return true
        }
        
        return false
    }

}
