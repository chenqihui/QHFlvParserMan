//
//  QHMP4Test.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/20.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

/*
 let vc = QHM3U8ViewController.create()
 //        vc.start(path: "http://127.0.0.1/resource/m3u8/seg/test.m3u8")
 //        vc.start(path: "http://10.7.66.56/resource/m3u8/ff/playlist.m3u8")
 vc.start(path: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
 */

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
         {
             undefine boxType == mdhd
             undefine boxType == hdlr
             undefine boxType == minf
             undefine boxType == mdhd
             undefine boxType == hdlr
             undefine boxType == minf
         }
     }
     offset = 846586
     header.size = 98
     header.type = udta
 }

 */


/*
 qihuideMacBook-Pro:Media chen$ ffmpeg -i dump.mp4 -movflags faststart good.mp4
 ffmpeg version 4.0 Copyright (c) 2000-2018 the FFmpeg developers
 built with Apple LLVM version 9.1.0 (clang-902.0.39.1)
 configuration: --prefix=/usr/local/Cellar/ffmpeg/4.0 --enable-shared --enable-pthreads --enable-version3 --enable-hardcoded-tables --enable-avresample --cc=clang --host-cflags= --host-ldflags= --enable-gpl --enable-libmp3lame --enable-libx264 --enable-libxvid --enable-opencl --enable-videotoolbox --disable-lzma
 libavutil      56. 14.100 / 56. 14.100
 libavcodec     58. 18.100 / 58. 18.100
 libavformat    58. 12.100 / 58. 12.100
 libavdevice    58.  3.100 / 58.  3.100
 libavfilter     7. 16.100 /  7. 16.100
 libavresample   4.  0.  0 /  4.  0.  0
 libswscale      5.  1.100 /  5.  1.100
 libswresample   3.  1.100 /  3.  1.100
 libpostproc    55.  1.100 / 55.  1.100
 Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'dump.mp4':
 Metadata:
 major_brand     : isom
 minor_version   : 512
 compatible_brands: isomiso2avc1mp41
 encoder         : Lavf58.12.100
 Duration: 00:00:12.73, start: 0.000000, bitrate: 537 kb/s
 Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 640x480, 483 kb/s, 13.82 fps, 15 tbr, 16k tbn, 30 tbc (default)
 Metadata:
 handler_name    : VideoHandler
 Stream #0:1(und): Audio: aac (HE-AAC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 47 kb/s (default)
 Metadata:
 handler_name    : SoundHandler
 Stream mapping:
 Stream #0:0 -> #0:0 (h264 (native) -> h264 (libx264))
 Stream #0:1 -> #0:1 (aac (native) -> aac (native))
 Press [q] to stop, [?] for help
 [libx264 @ 0x7feb8000ee00] using cpu capabilities: MMX2 SSE2Fast SSSE3 SSE4.2 AVX FMA3 BMI2 AVX2
 [libx264 @ 0x7feb8000ee00] profile High, level 2.2
 [libx264 @ 0x7feb8000ee00] 264 - core 152 r2854 e9a5903 - H.264/MPEG-4 AVC codec - Copyleft 2003-2017 - http://www.videolan.org/x264.html - options: cabac=1 ref=3 deblock=1:0:0 analyse=0x3:0x113 me=hex subme=7 psy=1 psy_rd=1.00:0.00 mixed_ref=1 me_range=16 chroma_me=1 trellis=1 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-2 threads=6 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=3 b_pyramid=2 b_adapt=1 b_bias=0 direct=1 weightb=1 open_gop=0 weightp=2 keyint=250 keyint_min=15 scenecut=40 intra_refresh=0 rc_lookahead=40 rc=crf mbtree=1 crf=23.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 ip_ratio=1.40 aq=1:1.00
 Output #0, mp4, to 'good.mp4':
 Metadata:
 major_brand     : isom
 minor_version   : 512
 compatible_brands: isomiso2avc1mp41
 encoder         : Lavf58.12.100
 Stream #0:0(und): Video: h264 (libx264) (avc1 / 0x31637661), yuv420p, 640x480, q=-1--1, 15 fps, 15360 tbn, 15 tbc (default)
 Metadata:
 handler_name    : VideoHandler
 encoder         : Lavc58.18.100 libx264
 Side data:
 cpb: bitrate max/min/avg: 0/0/0 buffer size: 0 vbv_delay: -1
 Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 128 kb/s (default)
 Metadata:
 handler_name    : SoundHandler
 encoder         : Lavc58.18.100 aac
 frame=   83 fps=0.0 q=27.0 size=     256kB time=00:00:05.75 bitrate= 364.3kbits/frame=  149 fps=144 q=27.0 size=     512kB time=00:00:10.12 bitrate= 414.4kbits/[mp4 @ 0x7feb8000ac00] Starting second pass: moving the moov atom to the beginning of the file
 frame=  192 fps=113 q=-1.0 Lsize=    1232kB time=00:00:12.72 bitrate= 793.2kbits/s dup=17 drop=0 speed=7.47x
 video:1020kB audio:204kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.640709%
 [libx264 @ 0x7feb8000ee00] frame I:1     Avg QP:19.19  size: 28902
 [libx264 @ 0x7feb8000ee00] frame P:49    Avg QP:21.19  size: 12147
 [libx264 @ 0x7feb8000ee00] frame B:142   Avg QP:26.86  size:  2958
 [libx264 @ 0x7feb8000ee00] consecutive B-frames:  0.5%  1.0%  4.7% 93.8%
 [libx264 @ 0x7feb8000ee00] mb I  I16..4:  9.0% 41.6% 49.4%
 [libx264 @ 0x7feb8000ee00] mb P  I16..4:  1.3%  6.1%  3.6%  P16..4: 20.3% 16.7% 12.1%  0.0%  0.0%    skip:40.0%
 [libx264 @ 0x7feb8000ee00] mb B  I16..4:  0.2%  0.8%  0.7%  B16..8: 25.8%  9.2%  2.5%  direct: 1.8%  skip:58.9%  L0:46.6% L1:38.8% BI:14.6%
 [libx264 @ 0x7feb8000ee00] 8x8 transform intra:51.4% inter:30.9%
 [libx264 @ 0x7feb8000ee00] coded y,uvDC,uvAC intra: 69.8% 63.0% 22.6% inter: 12.4% 6.6% 0.8%
 [libx264 @ 0x7feb8000ee00] i16 v,h,dc,p: 42% 15% 19% 24%
 [libx264 @ 0x7feb8000ee00] i8 v,h,dc,ddl,ddr,vr,hd,vl,hu: 37% 13% 18%  3%  7%  8%  5%  5%  4%
 [libx264 @ 0x7feb8000ee00] i4 v,h,dc,ddl,ddr,vr,hd,vl,hu: 27% 14% 16%  4% 10% 11%  7%  6%  5%
 [libx264 @ 0x7feb8000ee00] i8c dc,h,v,p: 54% 15% 27%  4%
 [libx264 @ 0x7feb8000ee00] Weighted P-Frames: Y:0.0% UV:0.0%
 [libx264 @ 0x7feb8000ee00] ref P L0: 59.6% 12.3% 16.4% 11.6%
 [libx264 @ 0x7feb8000ee00] ref B L0: 81.5% 14.1%  4.4%
 [libx264 @ 0x7feb8000ee00] ref B L1: 94.5%  5.5%
 [libx264 @ 0x7feb8000ee00] kb/s:652.59
 [aac @ 0x7feb8000c400] Qavg: 537.875
 */
