//
//  QHM3U8Test.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/26.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 
 // test.m3u8
 
 #EXTM3U
 #EXT-X-TARGETDURATION:5
 #EXT-X-VERSION:3
 #EXT-X-MEDIA-SEQUENCE:0
 #EXT-X-PLAYLIST-TYPE:VOD
 #EXTINF:5.00000,
 #EXT-X-BITRATE:893
 TEST0.ts
 #EXTINF:5.00000,
 #EXT-X-BITRATE:784
 TEST1.ts
 #EXTINF:2.67767,
 #EXT-X-BITRATE:722
 TEST2.ts
 #EXT-X-ENDLIST
 
 // playlist.m3u8
 
 #EXTM3U
 #EXT-X-VERSION:3
 #EXT-X-MEDIA-SEQUENCE:0
 #EXT-X-ALLOW-CACHE:YES
 #EXT-X-TARGETDURATION:13
 #EXTINF:12.933333,
 abc000.ts
 #EXT-X-ENDLIST
 
 // bipbopall.m3u8
 
 #EXTM3U
 #EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=200000
 gear1/prog_index.m3u8
 #EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=311111
 gear2/prog_index.m3u8
 #EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=484444
 gear3/prog_index.m3u8
 #EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=737777
 gear4/prog_index.m3u8
 
 */

/*
 资源 Media 里面的 fileSequence0.ts 是 bipbopall.m3u8 下载的第一个 m3u8 的第一个 ts 文件，即 gear1，
 通过上面 BANDWIDTH=200000，而下载的 ts 文件是 Content-Length：250228，时间：250228 / 200000 = 12s
 */

