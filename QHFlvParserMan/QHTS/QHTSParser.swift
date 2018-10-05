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
        var tsArr = [QHTS]()
        while offset < fileData.count {
            let endOffSet = offset + tsLength
            let tsData = fileData[offset..<endOffSet]
            let ts = tsPaser(data: tsData)
            tsArr.append(ts)
            offset = endOffSet
        }
        print("end")
    }
}
