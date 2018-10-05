//
//  QHM3U8Parser+Private.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/10/3.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

// Private
extension QHM3U8Parser {
    
    func p_valid(data: String?) -> Bool {
        if let m3u8String = data {
            return m3u8String.hasPrefix(kEXTM3U)
        }
        return false
    }
    
    func p_path2url(_ path: String) -> URL? {
        if let url = URL(string: path) {
            if url.pathExtension.uppercased() == kM3U8 {
                return url
            }
        }
        return nil
    }
    
    func p_getPlaylist(_ path: String, completionHandler: @escaping (String?) -> Swift.Void) {
        if let url = p_path2url(path) {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let err = error {
                    print("\(err)")
                }
                else {
                    if let d = data {
                        if let m3u8String = String(data: d, encoding: String.Encoding.utf8) {
                            //                            print("\(m3u8String)")
                            completionHandler(m3u8String)
                            return
                        }
                    }
                }
                completionHandler(nil)
            }
            dataTask.resume()
        }
        else {
            completionHandler(nil)
        }
    }
    
    // 下载 HLS 的播放文件 ts 或者 mp4
    func p_download(_ url: URL) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            if let locat = location {
                print("location:\(locat.relativeString)")
            }
        }
        downloadTask.resume()
    }
    
    func p_m3u8Parser(_ path: String, data d: String? = .none, completionHandler: @escaping (QHM3UObj?) -> Swift.Void) {
        if let data = d {
            if self.p_valid(data: data) == false {
                completionHandler(nil)
                return
            }
            let m3u8Arr = data.components(separatedBy: "\n") as [String]
            //            print("\(m3u8Arr)")
            
            var m3uObj = QHM3UObj(path: path)
            m3uObj.type = typeParser(m3u8Arr)
            m3uObj.headerTag = headerParser(m3u8Arr)
            m3uObj.bodyArr = bodyParser(path, m3u8Arr)
            
            if m3uObj.bodyArr.count > 0 {
                if var body = m3uObj.bodyArr.first {
                    if let bodyUrl = body.url {
                        if var subUrl = URL(string: bodyUrl) {
                            if body.isAP == false {
                                if var url = m3uObj.relativePath {
                                    url.appendPathComponent(bodyUrl)
                                    subUrl = url
                                }
                            }
                            
                            if subUrl.pathExtension.uppercased() == kM3U8 {
                                m3u8Parser(subUrl.relativeString) { (obj) in
                                    if let o = obj {
                                        m3uObj.subM3UObj = [o]
                                    }
                                    completionHandler(m3uObj)
                                }
                                return
                            }
                            else {
                                //                                p_download(subUrl)
                            }
                        }
                    }
                }
            }
            completionHandler(m3uObj)
        }
        else {
            p_getPlaylist(path) { (data) in
                self.m3u8Parser(path, data: data, completionHandler: { (m3uObj) in
                    completionHandler(m3uObj)
                })
            }
        }
    }
}
