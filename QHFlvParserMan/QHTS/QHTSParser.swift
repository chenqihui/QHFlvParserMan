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
    var tsArr = [QHTS]()
    var h264PIDs = [Int]()
    var ACCPIDs = [Int]()
    var MP3PIDs = [Int]()
    
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
        var id = 0
        while offset < fileData.count {
            let endOffSet = offset + tsLength
            let tsData = fileData[offset..<endOffSet]
            var ts = tsPaser(data: tsData)
            ts.id = id
            tsArr.append(ts)
            offset = endOffSet
            id += 1
        }
        print("end")
    }
}
