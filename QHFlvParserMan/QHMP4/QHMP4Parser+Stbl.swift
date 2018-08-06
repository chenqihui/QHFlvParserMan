//
//  QHMP4Parser+Stbl.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 stbl
 
 1.stsd
 利用sample description atom存储的信息可以正确的解码media sample。不同的媒体类型存储不同的sample description，例如，视频媒体，sample description就是图像的结构。第四章解释了不同媒体类型对应的sample description信息。
 sample description atom的类型是'stsd'，包含了一个sample description表。根据不同的编码方案和存储数据的文件数目，每个media可以有一个到多个sample description。sample-to-chunk atom通过这个索引表，找到合适medai中每个sample的description。
 box header和version字段后会有一个entry count字段，根据entry的个数，每个entry会有type信息，如“vide”、“sund”等，根据type不同sample description会提供不同的信息，例如对于video track，会有“VisualSampleEntry”类型信息，对于audio track会有“AudioSampleEntry”类型信息。
 
 视频的编码类型、宽高、长度，音频的声道、采样等信息都会出现在这个box中。
 
 对应得的数据格式是'mp4a'，14496-12定义了这种结构，mp4解码器会识别此description
 2.stts
 Time-to-sample atoms存储了media sample的duration 信息，提供了时间对具体data sample的映射方法，通过这个atom，你可以找到任何时间的sample，类型是'stts'。
 
 这个atom可以包含一个压缩的表来映射时间和sample序号，用其他的表来提供每个sample的长度和指针。表中每个条目提供了在同一个时间偏移量里面连续的sample序号， 以及samples的偏移量。递增这些偏移量，就可以建立一个完整的time-to-sample表，计算公式如下
 
 DT(n+1) = DT(n) + STTS(n)
 
 其中STTS(n)是没有压缩的STTS第n项信息，DT是第n个sample的显示时间。Sample的排列是按照时间戳的顺序，这样偏移量永远是非负的。DT一般以0开始，如果不为0，edit list atom 设定初始的DT值。DT计算公式如下
 
 DT(i) = SUM (for j=0 to i-1 of delta(j))
 
 所有偏移量的和就是track中media的长度，这个长度不包括media的time scale，也不包括任何edit list
 3.stss
 sync sample atom确定media中的关键帧。对于压缩的媒体，关键帧是一系列压缩序列的开始帧，它的解压缩是不依赖于以前的帧。后续帧的解压缩依赖于这个关键帧。
 
 sync sample atom可以非常紧凑的标记媒体内的随机存取点。它包含一个sample序号表，表内的每一项严格按照sample的序号排列，说明了媒体中的哪一个sample是关键帧。如果此表不存在，说明每一个sample都是一个关键帧，是一个随机存取点。
 4.ctts
 5.stsc
 Sample-to-Chunk Atoms
 当添加samples到media时，用chunks组织这些sample，这样可以方便优化数据获取。一个trunk包含一个或多个sample，chunk的长度可以不同，chunk内的sample的长度也可以不同。sample-to-chunk atom存储sample与chunk的映射关系。
 6.stsz
 sample size atoms定义了每个sample的大小，它的类型是'stsz'，包含了媒体中全部sample的数目和一张给出每个sample大小的表。这样，媒体数据自身就可以没有边框的限制。
 “stsz” 定义了每个sample的大小，包含了媒体中全部sample的数目和一张给出每个sample大小的表。这个box相对来说体积是比较大的。
 7.stco
 Chunk offset atoms 定义了每个trunk在媒体流中的位置，它的类型是'stco'。位置有两种可能，32位的和64位的，后者对非常大的电影很有用。在一个表中只会有一种可能，这个位置是在整个文件中的，而不是在任何atom中的，这样做就可以直接在文件中找到媒体数据，而不用解释atom。需要注意的是一旦前面的atom有了任何改变，这张表都要重新建立，因为位置信息已经改变了。
 8.sgpd
 9.sbgp
 */

import Cocoa

func stsdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var arr = [[String: Any]]()
        for _ in 0..<Int(entryCount) {
            // 这个sample description的字节数
            let size = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            // 存储数据的格式。
            let type = QHParserUtil.hexToString(data: data, startIndex: index + 4, length: 4)
            // reserved
            // index + 4 + 6
            // 数据引用索引
            let refence = QHParserUtil.hexToDecimal(data: data, startIndex: index + 10, count: 2)
            
            arr.append(["size": size,
                        "type": type,
                        "refence": refence])
            
            index += Int(size)
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
    }
    return dicValue
}

func sttsParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var arr = [[String: Any]]()
        var duration: UInt64 = 0
        for _ in 0..<Int(entryCount) {
            // 有相同duration的连续sample的数目
            let sampleCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            // 每个sample的duration
            let sampleDuration = QHParserUtil.hexToDecimal(data: data, startIndex: index + 4, count: 4)
            duration += sampleCount*sampleDuration
            
            arr.append(["sampleCount": sampleCount,
                        "sampleDuration": sampleDuration])
            
            index += 8
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
        dicValue["duration"] = duration
    }
    
    return dicValue
}

func stssParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var arr = [[String: Any]]()
        for _ in 0..<Int(entryCount) {
            // 是关键帧的sample序号
            let sampleSequence = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            
            arr.append(["sampleSequence": sampleSequence])
            
            index += 4
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
    }
    return dicValue
}

func stscParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var arr = [[String: Any]]()
        for _ in 0..<Int(entryCount) {
            // 这个table使用的第一个chunk序号
            let firstChunk = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            // 当前trunk内的sample数目
            let samplesPerChunk = QHParserUtil.hexToDecimal(data: data, startIndex: index + 4, count: 4)
            // 与这些sample关联的sample description的序号
            let sampleDescriptionID = QHParserUtil.hexToDecimal(data: data, startIndex: index + 8, count: 4)
            
            arr.append(["firstChunk": firstChunk,
                        "samplesPerChunk": samplesPerChunk,
                        "sampleDescriptionID": sampleDescriptionID])
            
            index += 12
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
    }
    return dicValue
}

func stszParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        // 全部sample的数目。如果所有的sample有相同的长度，这个字段就是这个值。否则，这个字段的值就是0。那些长度存在sample size表中
        var sampleSize = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        dicValue["flags"] = flags
        
        if sampleSize == 0 {
            // sample size表的结构。这个表根据sample number索引，第一项就是第一个sample，第二项就是第二个sample
            let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            index += 4
            
            var arr = [[String: Any]]()
            for _ in 0..<Int(entryCount) {
                // 每个sample的大小
                let sampleSubSize = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
                sampleSize += sampleSubSize
                arr.append(["sampleSubSize": sampleSubSize])
                
                index += 4
            }
            
            dicValue["entryCount"] = entryCount
            dicValue["entryInfo"] = arr
        }
        
        dicValue["sampleSize"] = sampleSize
    }
    return dicValue
}

func stcoParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        let entryCount = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
        index += 4
        
        var arr = [[String: Any]]()
        // 字节偏移量从文件开始到当前chunk。这个表根据chunk number索引，第一项就是第一个trunk，第二项就是第二个trunk
        for _ in 0..<Int(entryCount) {
            // 每个sample的大小
            let chunkOffset = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 4)
            
            arr.append(["chunkOffset": chunkOffset])
            
            index += 4
        }
        
        dicValue["flags"] = flags
        dicValue["entryCount"] = entryCount
        dicValue["entryInfo"] = arr
    }
    return dicValue
}
