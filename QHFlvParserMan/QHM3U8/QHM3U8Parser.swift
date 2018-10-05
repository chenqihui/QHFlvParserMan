//
//  QHM3U8Parser.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/25.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHM3U8Parser: NSObject {
    
    var path: String!
    
    init(path p: String) {
        path = p
    }
}

extension QHM3U8Parser {
    
    func getPlaylist(_ path: String, completionHandler: @escaping (String?) -> Swift.Void) {
        p_getPlaylist(path) { (data) in
            completionHandler(data)
        }
    }
    
    func valid(_ path: String, completionHandler: @escaping (Bool) -> Swift.Void) {
        p_getPlaylist(path) { (data) in
            completionHandler(self.p_valid(data: data))
        }
    }
    
    func m3u8Parser(_ path: String, data d: String? = .none, completionHandler: @escaping (QHM3UObj?) -> Swift.Void) {
        p_m3u8Parser(path, data: d) { (obj) in
            completionHandler(obj)
        }
    }
}

// Test
extension QHM3U8Parser {
    
    func test() {
        //        valid(path) { (bValid) in
        //            print("\(bValid ? "是 M3U8 文件" : "不是 M3U8 文件")")
        //        }
        // 2、
        m3u8Parser(path) { (m3uObj) in
            if let obj = m3uObj {
                print("\(obj)")
            }
        }
        // 3、
        //        getPlaylist(path) { (data) in
        //            self.m3u8Parser(self.path, data: data, completionHandler: { (m3uObj) in
        //                if let obj = m3uObj {
        //                    print("\(obj)")
        //                }
        //            })
        //        }
    }
}
