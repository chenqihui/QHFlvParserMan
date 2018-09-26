//
//  MainViewController.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/6/20.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let vc = QHM3U8ViewController.create()
        vc.start(path: "http://127.0.0.1/resource/m3u8/seg/test.m3u8")
//        vc.start(path: "http://10.7.66.56/resource/m3u8/ff/playlist.m3u8")
//        vc.start(path: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
    }
    
    
    @IBAction func chooseAction(_ sender: NSButton) {
        let myFiledialog = NSOpenPanel()
        myFiledialog.prompt = "Select flv path"
        myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.canChooseFiles = true
        myFiledialog.resolvesAliases = true
        myFiledialog.beginSheetModal(for: self.view.window!, completionHandler: { num in
            if num == NSApplication.ModalResponse.OK {
                myFiledialog.close()
                let url = myFiledialog.url!
                let pathExtension = url.pathExtension.uppercased()
                var window: NSWindow?
                if pathExtension == "FLV" {
                    let vc = ViewController.create()
                    window = NSWindow(contentViewController: vc)
                    vc.start(path: url.path)
                }
                else if pathExtension == "MP4" {
                    let vc = QHMP4ViewController.create()
                    window = NSWindow(contentViewController: vc)
                    vc.start(path: url.path)
                }
                else if pathExtension == "M3U8" {
                    let vc = QHM3U8ViewController.create()
                    window = NSWindow(contentViewController: vc)
                    vc.start(path: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
                }
                if let w = window {
                    w.orderFront(nil)
                    w.title = url.path
                }
            }
            else {
                myFiledialog.close()
            }
        })
    }
    
}
