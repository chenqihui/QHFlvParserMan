//
//  QHMP4Parser+Minf.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/24.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 minf
 
 1.vmhd
 Video media information header atoms 定义颜色和图形模式信息。
 2.smhd
 Sound media information atoms是音频媒体的第一层atoms，包含其他的定义音频媒体数据的特性
 3.dinf
    container box
 handler reference定义data handler component如何获取媒体数据，data handler用这些数据信息来解释媒体数据。Data information atoms的类型是'dinf'。它是一个容器atom，包含其他的子atom。
 “dinf”解释如何定位媒体信息，是一个container box。“dinf”一般包含一个“dref”，即data reference box；“dref”下会包含若干个“url”或“urn”，这些box组成一个表，用来定位track数据。简单的说，track可以被分成若干段，每一段都可以根据“url”或“urn”指向的地址来获取数据，sample描述中会用这些片段的序号将这些片段组成一个完整的track。一般情况下，当数据被完全包含在文件中时，“url”或“urn”中的定位字符串是空的。
 4.stbl
    container box
 sample table atom包含转化媒体时间到实际的sample的信息，他也说明了解释sample的信息，例如，视频数据是否需要解压缩，解压缩算法是什么？它的类型是'stbl'，是一个容器atom，包含sample description atom, time-to-sample atom, sync sample atom, sample-to-chunk atom, sample size atom, chunk offset atom和shadow sync atom.
 
 sample table atom 包含track中media sample的所有时间和数据索引，利用这个表，就可以定位sample到媒体时间，决定其类型，大小，以及如何在其他容器中找到紧邻的sample。
 
 如果sample table atom所在的track没有引用任何数据，那么它就不是一个有用的media track，不需要包含任何子atom。
 
 如果sample table atom所在的track引用了数据，那么必须包含以下的子atom：sample description, sample size, sample to chunk和chunk offset。所有的子表有相同的sample数目。
 
 sample description atom 是必不可少的一个atom，而且必须包含至少一个条目，因为它包含了数据引用atom检索media sample的目录信息。没有sample description，就不可能计算出media sample存储的位置。sync sample atom 是可选的，如果没有，表明所有的samples都是sync samples。
 */

import Cocoa

func vmhdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        // 视频合成模式，为0时拷贝原始图像，否则与opcolor进行合成
        let graphicsMode = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let red = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let green = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let blue = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        
        dicValue["flags"] = flags
        dicValue["graphicsMode"] = graphicsMode
        // ｛red，green，blue｝
        dicValue["opcolor"] = "{\(red), \(green), \(blue)}"
    }
    return dicValue
}

func smhdParser(data: Data) -> [String: Any] {
    
    var dicValue = [String: Any]()
    
    var index = data.startIndex
    let version = uint(data[index])
    dicValue["version"] = version
    
    if version == 0 {
        let flags = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 3)
        index += 3
        // 音频的均衡是用来控制计算机的两个扬声器的声音混合效果，一般是0。一般值是0。立体声平衡，[8.8] 格式值，一般为0，-1.0表示全部左声道，1.0表示全部右声道
        let balance1 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        let balance2 = QHParserUtil.hexToDecimal(data: data, startIndex: index, count: 2)
        index += 2
        // reserved
        index += 2
        
        dicValue["flags"] = flags
        dicValue["balance"] = "\(balance1).\(balance2)"
    }
    return dicValue
}
