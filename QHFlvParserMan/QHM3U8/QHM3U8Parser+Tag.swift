//
//  QHM3U8Parser+Tag.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/26.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

extension QHM3U8Parser {
    
    func tagParser(_ tagString: String) -> QHM3UTag? {
        if tagString.count > 0, tagString.hasPrefix("#") == true {
            let tagArr = tagString.components(separatedBy: ":")
            if tagArr.count > 0 {
                let key = tagArr[0]
                var tag = QHM3UTag(tag: key)
                if tagArr.count > 1 {
                    let value = tagArr[1]
                    
                    let propertysArr = value.components(separatedBy: ",")
                    for propertysString in propertysArr {
                        if propertysString == "\t" {
                            continue
                        }
                        let propertyArr = propertysString.components(separatedBy: "=")
                        if propertyArr.count == 2 {
                            let key = propertyArr[0].trimmingCharacters(in: .whitespaces)
                            let value = propertyArr[1].trimmingCharacters(in: .whitespaces)
                            let property = QHM3UTagProperty(key: key, value: value)
                            tag.value.append(property)
                        }
                        else {
                            let property = QHM3UTagProperty(key: "", value: propertysString)
                            tag.value.append(property)
                        }
                    }
                }
                return tag
            }
            return QHM3UTag(tag: tagString)
        }
        else {
            return nil
        }
    }
}
