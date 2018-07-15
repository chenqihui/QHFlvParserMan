//
//  QHFlvParser+Audio.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/16.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

/*
 音视频解析数据
 */
extension QHFlvParser {
    //3、audio data
    func audio(_ data: Data) -> QHAudioTag {
        var index = data.startIndex
        var tag = QHAudioTag()
        let v1 = uint(data[index])
        //3.1、高4位为1010，转十进制为10，表示Audio的编码格式为AAC；
        tag.soundFormat = uint(v1>>4)//10为AAC
        //3.2、第3、2位为11，转十进制为3，表示该音频的采样率为44KHZ；
        let v1_2 = v1 & 0b00001100
        if v1_2>>2 == 3 {
            tag.soundRate = "44KHZ"
        }
        else if v1_2>>2 == 2 {
            tag.soundRate = "22KHZ"
        }
        else if v1_2>>2 == 1 {
            tag.soundRate = "11KHZ"
        }
        else if v1_2>>2 == 0 {
            tag.soundRate = "5.5KHZ"
        }
        //3.3、第1位为1，表示该音频采样点位宽为16bits；
        let v1_3 = v1 & 0b00000010
        if v1_3>>1 == 1 {
            tag.soundSize = "16bits"
        }
        else if v1_3>>1 == 0 {
            tag.soundSize = "8bits"
        }
        //3.4、第0位为1，表示该音频为立体声。
        let v1_4 = v1 & 0b00000001
        if v1_4 == 1 {
            tag.soundType = "立体声"
        }
        else if v1_4 == 0 {
            tag.soundType = "单声道"
        }
        //3.5、AudioSpecificConfig
        /*
         为什么AudioTagHeader中定义了音频的相关参数，我们还需要传递AudioSpecificConfig呢？
         
         因为当SoundFormat为AAC时，SoundType须设置为1（立体声），SoundRate须设置为3（44KHZ），但这并不意味着FLV文件中AAC编码的音频必须是44KHZ的立体声。播放器在播放AAC音频时，应忽略AudioTagHeader中的参数，并根据AudioSpecificConfig来配置正确的解码参数。
         */
        if tag.soundFormat == 10 {
            //3.6、Audio的编码格式为AAC，并且十进制为0时，说明AACAUDIODATA中存放的是AAC sequence header，为0时，说明AACAUDIODATA中存放的是AAC raw；
            index += 1
            let v1 = uint(data[index])
            tag.aacPackType = v1
            if v1 == 0 {//AAC sequence header
                //AudioSpecificConfig，再拿具体配置
            }
            else {
                //aac raw
            }
            
            //3.7、AUDIODATA数据，即AAC sequence header。
        }
        index += 1
        tag.audioBody = data[index..<data.endIndex]
        return tag
    }
}
