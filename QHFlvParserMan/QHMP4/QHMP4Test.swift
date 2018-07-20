//
//  QHMP4Test.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/20.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 value == isom
 value == ....
 value == isom
 value == iso2
 
 offset = 0
 header.size = 32
 header.type = ftyp
 offset = 0
 header.size = 8
 header.type = free
 offset = 0
 header.size = 846538
 header.type = mdat
 offset = 0
 header.size = 8857
 header.type = moov
 {
 offset = 846586
 header.size = 108
 header.type = mvhd
 offset = 846586
 header.size = 4414
 header.type = trak
 {
 offset = 846702
 header.size = 92
 header.type = tkhd
 offset = 846702
 header.size = 48
 header.type = edts
 offset = 846702
 header.size = 4266
 header.type = mdia
 }
 offset = 846586
 header.size = 4229
 header.type = trak
 {
 offset = 851116
 header.size = 92
 header.type = tkhd
 offset = 851116
 header.size = 36
 header.type = edts
 offset = 851116
 header.size = 4093
 header.type = mdia
 }
 offset = 846586
 header.size = 98
 header.type = udta
 }

 */
