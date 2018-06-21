//
//  QHFlvObject.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/6/17.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

/*
 参考：
 [FFmpeg从入门到出家（FLV文件结构解析） - 简书](https://www.jianshu.com/p/d68d6efe8230)
 */

/*
 464c 5601 0500 0000 09                         h
                       00 0000 00               preSize
                                 12 0001        s-h
 2500 0000 0000 0000
                     0200 0a6f 6e4d 6574        s-b
 6144 6174 6108 0000 000d 0008 6475 7261
 7469 6f6e 0040 4055 3f7c ed91 6800 0577
 6964 7468 0040 8400 0000 0000 0000 0668
 6569 6768 7400 407e 0000 0000 0000 000d
 7669 6465 6f64 6174 6172 6174 6500 407e
 8480 0000 0000 0009 6672 616d 6572 6174
 6500 402e 0000 0000 0000 000c 7669 6465
 6f63 6f64 6563 6964 0040 1c00 0000 0000
 0000 0d61 7564 696f 6461 7461 7261 7465
 0040 4770 0000 0000 0000 0f61 7564 696f
 7361 6d70 6c65 7261 7465 0040 e588 8000
 0000 0000 0f61 7564 696f 7361 6d70 6c65
 7369 7a65 0040 3000 0000 0000 0000 0673
 7465 7265 6f01 0100 0c61 7564 696f 636f
 6465 6369 6400 4024 0000 0000 0000 0007
 656e 636f 6465 7202 000d 4c61 7666 3538
 2e31 322e 3130 3000 0866 696c 6573 697a
 6500 4141 53e3 0000 0000 0000 09
                                 00 0001        preSize
 30
   09 0000 2c00 0000 0000 0000                  v-h
                               1700 0000        v-b
 0001 6400 16ff e100 1867 6400 16ac d900
 a03d a100 0003 0001 0000 0300 1e0f 162d
 9601 0004 68ea 8f2c
                     0000 0037                  preSize
                               0800 0007        a-h
 0000 0000 0000 00
                  af 0013 9056 e5a0             a-b
                                    0000        preSize
 0012
      0900 7f3a 0000 0000 0000 0017 0100
 00c8 0000 7f31 6588 8200 3af1 4e17 b184
 5cdf e07b 1538 7fcf 312c 93ae 7f25 acf9
 b59e 36e1 72cd 11fe 80a8 5575 5c79 b8d5
 7f50 c795 c3b6 9da7 d118 c593 14e1 5037
 cdef f5f0 01d2 3d45 b1e8 cdec eb8b f760
 */

enum QHFlvType {
    case none
    case videoAndAudio
    case videoOnly
    case audioOnly
}

enum QHFlvTagType {
    case none
    case header
    case script
    case video
    case audio
}

struct QHFlvBody {
    let id: uint
    var offset: uint
    var format: String {
        get {
            if tag.tagType == .audio, let audiobody = tag.tagBody as? QHAudioTag {
                if audiobody.soundFormat == 10 {
                    return "AAC"
                }
            }
            else if tag.tagType == .video, let videobody = tag.tagBody as? QHVideoTag {
                if videobody.codecID == 7 {
                    return "AVC"
                }
            }
            return "n/a"
        }
    }
    var ext: String?
    var tag: QHFlvTag
    var previousTagSize: uint
    
    init(id: uint, tag: QHFlvTag) {
        self.id = id
        self.tag = tag
        offset = 0
        previousTagSize = 0
    }
}

struct QHFlvTag {
    var signature: Bool
    var filter: uint
    var tagType: QHFlvTagType
    var dataSize: uint
    var timestamp: uint
    var timestampExtended: uint
    var streamID: uint
    var tagBody: Any?
    
    init() {
        signature = false
        filter = 0
        tagType = .none
        dataSize = 0
        timestamp = 0
        timestampExtended = 0
        streamID = 0
    }
}

struct QHAudioTag {
    var soundFormat: uint
    var soundRate: String?
    var soundSize: String?
    var soundType: String?
    var accPackType: uint
    var audioBody: Any
    
    init() {
        soundFormat = 0
        accPackType = 0
        audioBody = 0
    }
}

struct QHVideoTag {
    var frameType: uint//1为关键帧
    var codecID: uint
    var avcPackType: uint
    var compositionTime: uint
    var videoBody: Any
    
    init() {
        frameType = 0
        codecID = 0
        avcPackType = 0
        compositionTime = 0
        videoBody = 0
    }
}

class QHFlvObject: NSObject {
    
    let fileData: Data
    let previousTagSizeBytes: uint = 4
    let tagSizeBytesExceptHeaderAndBody: uint = 11
    
    var flvOffset: uint = 0
    var flvBodys = [QHFlvBody]()
    
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
            
            let _ = filePaser()
        }
        else {
            print("不是 flv 文件")
        }
    }
    
    func filePaser() -> Bool {
        if isFlvFile() {
            var flvTag = QHFlvTag()
            flvTag.tagType = .header
            flvTag.dataSize = headerLength()
            var flvBody = QHFlvBody(id: 0, tag: flvTag)
            flvBody.offset = flvOffset
            flvBodys.append(flvBody)
            
            flvOffset += flvTag.dataSize - 1 //偏移值，从 0 开始
            
            var id: uint = 1
            while flvOffset < fileData.count {
                let previousTagSizeTemp = previousTagSize()
                flvOffset += previousTagSizeBytes
                
                flvTag = tag()
                flvBody.previousTagSize = previousTagSizeTemp
                flvBody.tag = flvTag
                flvBody = QHFlvBody(id: id, tag: flvTag)
                flvBody.offset = (flvOffset - previousTagSizeBytes)
                flvBodys.append(flvBody)
                
                flvOffset += flvBody.tag.dataSize + tagSizeBytesExceptHeaderAndBody
                id += 1
//                if id == 6 {
//                    break
//                }
            }
            return true
        }
        
        return false
    }
}

//QHFlvHeader
/*
 1、FLV Header：位置0x00000000 - 0x00000008, 共9个字节，为FLV Header
 */
extension QHFlvObject {
    
    //1.1、0x00000000 - 0x00000002 : 0x46 0x4C 0x56分别表示字符'F''L''V'，用来标识这个文件是FLV格式的。在做格式探测的时候，如果发现前3个字节为“FLV”，就认为它是FLV文件；
    func isFlvFile() -> Bool {
        if fileData.count > 3 {
            let v0 = String(fileData[0], radix: 16)
            let v1 = String(fileData[1], radix: 16)
            let v2 = String(fileData[2], radix: 16)
            if v0 == "46" && v1.uppercased() == "4C" && v2 == "56" {
                return true
            }
        }
        return false
    }
    
    //1.2、0x00000003 : 0x01, 表示FLV版本号；
    func version() -> uint {
        if fileData.count > 4 {
            return uint(fileData[3])
        }
        return 0
    }
    
    //1.3、0x00000004 : 0x05, 转换为2进制是0000 0101，其中第0位为1，表示存在video，第2位为1，表示存在audio；
    func type() -> QHFlvType {
        if fileData.count > 5 {
            let v4 = uint(fileData[4])
            if v4 & 0b00000001 == 0b00000001 && v4 & 0b00000100 == 0b00000100 {
                return .videoAndAudio
            }
            else if v4 & 0b00000001 == 0b00000001 {
                return .videoOnly
            }
            else if v4 & 0b00000100 == 0b00000100 {
                return .audioOnly
            }
        }
        return .none
    }
    
    //1.4、0x00000005 - 0x00000008 : 0x00 0x00 0x00 0x09，转十进制为9，表示FLV header的长度，当FLV 版本号为1时，该值通常为9。
    func headerLength() -> uint {
        if fileData.count > 9 {
            let v5 = uint(fileData[5])
            let v6 = uint(fileData[6])
            let v7 = uint(fileData[7])
            let v8 = uint(fileData[8])
            let l1 = v5 * 1<<24
            let l2 = v6 * 1<<16
            let length = l1 + l2 + v7 * 1<<8 + v8
            return uint(length)
        }
        return 0
    }
}

//QHFlvBody
/*
 2、FLV File Body - 由一连串的PreviousTagSize + Tag构成。previousTagSize是4个字节的数据，表示前一个tag的size。
 */
extension QHFlvObject {
    //2.1、PreviousTagSize的长度为4个字节，用来表示前一个Tag的长度
    private func previousTagSize() -> uint {
        if fileData.count > flvOffset + previousTagSizeBytes {
            let v1 = uint(fileData[Int(flvOffset + 1)])
            let v2 = uint(fileData[Int(flvOffset + 2)])
            let v3 = uint(fileData[Int(flvOffset + 3)])
            let v4 = uint(fileData[Int(flvOffset + 4)])
            let l1 = v1 * 1<<24
            let l2 = v2 * 1<<16
            let size = l1 + l2 + v3 * 1<<8 + v4
            
            return size
        }
        return 0
    }
    
    //2.2、Tag里面的数据可能是video、audio或者scripts
    private func tag() -> QHFlvTag {
        var tag = QHFlvTag()
        if fileData.count > flvOffset + tagSizeBytesExceptHeaderAndBody {
            let v1 = uint(fileData[Int(flvOffset + 1)])
            //2.2.1、0x08, 二进制为0000 1000，第5位为0, 表示为非加扰文件;
            if v1 & 0b00100000 == 0b00100000 {
                //加扰文件
                tag.signature = true
            }
            else {
                //非加扰文件
                tag.signature = false
            }
            //2.2.2、低5位01000为8，说明这个Tag包含的数据类型为Audio；
            let v1_2 = v1 & 0b00011111
            if v1_2 == 8 {
                tag.tagType = .audio
            }
            else if v1_2 == 9 {
                tag.tagType = .video
            }
            /*
            2.2.3
            [3.5 Script Data Tags]
             如果TAG包中的TagType等于18，表示该Tag中包含的数据类型为SCRIPT。
             
             SCRIPTDATA 结构十分复杂，定义了很多格式类型，每个类型对应一种结构
             
             [E.5 onMetaData]是SCRIPTDATA中一个非常重要的信息，其结构定义可参考E.5 onMetaData。它通常是FLV文件中的第一个Tag，用来表示当前文件的一些基本信息: 比如视音频的编码类型id、视频的宽和高、文件大小、视频长度、创建日期等。
             */
            else if v1_2 == 18 {
                tag.tagType = .script
            }
            //2.2.4、Tag的内容长度为，与该tag后面的previousTagSize() - 11相同；
            let v2 = uint(fileData[Int(flvOffset + 2)])
            let v3 = uint(fileData[Int(flvOffset + 3)])
            let v4 = uint(fileData[Int(flvOffset + 4)])
            
            tag.dataSize = v2 * 1<<16 + v3 * 1<<8 + v4
            
            //2.2.5、当前Audio数据的时间戳；
            let v5 = uint(fileData[Int(flvOffset + 5)])
            let v6 = uint(fileData[Int(flvOffset + 6)])
            let v7 = uint(fileData[Int(flvOffset + 7)])
            
            tag.timestamp = v7 * 1<<16 + v6 * 1<<8 + v5
            
            //2.2.6、扩展时间戳，如果扩展时间戳不为0，那么该Tag的时间戳应为：Timestamp | TimestampExtended<<24；
            let v8 = uint(fileData[Int(flvOffset + 8)])
            
            tag.timestampExtended = v8
            
            //2.2.7、StreamID
            let v9 = uint(fileData[Int(flvOffset + 9)])
            let v10 = uint(fileData[Int(flvOffset + 10)])
            let v11 = uint(fileData[Int(flvOffset + 11)])
            
            tag.streamID = v11 * 1<<16 + v10 * 1<<8 + v9
            
            //2.2.8、解析音视频数据
            let startIndex = uint(flvOffset + 11) + 1
            let endIndex = startIndex + tag.dataSize
            var fileDataTemp = fileData
            let parserData = fileDataTemp[startIndex..<endIndex]
            if tag.tagType == .audio {
                tag.tagBody = audioParser(audioData: parserData)
            }
            else if tag.tagType == .video {
                tag.tagBody = videoParser(videoData: parserData)
            }
        }
        return tag
    }
}

/*
 音视频解析数据
 */
extension QHFlvObject {
    //3、audio data
    private func audioParser(audioData: Data) -> QHAudioTag {
        var audioTag = QHAudioTag()
        let v1 = uint(audioData[audioData.startIndex])
        //3.1、高4位为1010，转十进制为10，表示Audio的编码格式为AAC；
        audioTag.soundFormat = uint(v1>>4)//10为AAC
        //3.2、第3、2位为11，转十进制为3，表示该音频的采样率为44KHZ；
        let v1_2 = v1 & 0b00001100
        if v1_2>>2 == 3 {
            audioTag.soundRate = "44KHZ"
        }
        else if v1_2>>2 == 2 {
            audioTag.soundRate = "22KHZ"
        }
        else if v1_2>>2 == 1 {
            audioTag.soundRate = "11KHZ"
        }
        else if v1_2>>2 == 0 {
            audioTag.soundRate = "5.5KHZ"
        }
        //3.3、第1位为1，表示该音频采样点位宽为16bits；
        let v1_3 = v1 & 0b00000010
        if v1_3>>1 == 1 {
            audioTag.soundSize = "16bits"
        }
        else if v1_3>>1 == 0 {
            audioTag.soundSize = "8bits"
        }
        //3.4、第0位为1，表示该音频为立体声。
        let v1_4 = v1 & 0b00000001
        if v1_4 == 1 {
            audioTag.soundType = "立体声"
        }
        else if v1_4 == 0 {
            audioTag.soundType = "单声道"
        }
        //3.5、AudioSpecificConfig
        /*
         为什么AudioTagHeader中定义了音频的相关参数，我们还需要传递AudioSpecificConfig呢？
         
         因为当SoundFormat为AAC时，SoundType须设置为1（立体声），SoundRate须设置为3（44KHZ），但这并不意味着FLV文件中AAC编码的音频必须是44KHZ的立体声。播放器在播放AAC音频时，应忽略AudioTagHeader中的参数，并根据AudioSpecificConfig来配置正确的解码参数。
         */
        if audioTag.soundFormat == 10 {
            //3.6、Audio的编码格式为AAC，并且十进制为0时，说明AACAUDIODATA中存放的是AAC sequence header，为0时，说明AACAUDIODATA中存放的是AAC raw；
            let v1 = uint(audioData[audioData.startIndex + 1])
            audioTag.accPackType = v1
            if v1 == 0 {//AAC sequence header
                //AudioSpecificConfig，再拿具体配置
                
            }
            
            //3.7、AUDIODATA数据，即AAC sequence header。
            audioTag.audioBody = audioData[audioData.startIndex + 2..<audioData.endIndex]
        }
        else {
            audioTag.audioBody = audioData[audioData.startIndex + 1..<audioData.endIndex]
        }
        return audioTag
    }
    
    //4、video data
    private func videoParser(videoData: Data) -> QHVideoTag {
        var videoTag = QHVideoTag()
        let v1 = uint(videoData[videoData.startIndex])
        //4.1、高4位为0001，转十进制为1，表示当前帧为关键帧；
        let v1_1 = v1 & 0b11110000
        if v1_1>>4 == 1 {
            videoTag.frameType = 1
        }
        //4.2、低4位为0111，转十进制为7，说明当前视频的编码格式为AVC
        let v1_2 = v1 & 0b00001111
        videoTag.codecID = v1_2//7为AVC
        //4.3、十进制为0，并且Video的编码格式为AVC，说明VideoTagBody中存放的是AVC sequence header
        let v2 = uint(videoData[videoData.startIndex + 1])
        
        //4.4、AVCPacketType 表示接下来 VIDEODATA （AVCVIDEOPACKET）的内容
        videoTag.avcPackType = v2
        if v2 == 0 {
            //AVCDecoderConfigurationRecord（AVC sequence header）
        }
        else if v2 == 1 {
            //One or more NALUs (Full frames are required)
        }
        
        let v3 = uint(videoData[videoData.startIndex + 2])
        let v4 = uint(videoData[videoData.startIndex + 3])
        let v5 = uint(videoData[videoData.startIndex + 4])
        
        //4.5、CompositonTime相对时间戳，如果AVCPacketType=0x01，为相对时间戳，其它均为0；
        videoTag.compositionTime = v3 * 1<<16 + v4 * 1<<8 + v5
        
        //4.6、VIDEODATA数据，即AVC sequence header
        videoTag.videoBody = videoData[videoData.startIndex + 5..<videoData.endIndex]
        
        return videoTag
    }
}
