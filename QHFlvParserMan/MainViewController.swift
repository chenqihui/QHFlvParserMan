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
                
                let vc = ViewController.create()
                let w = NSWindow(contentViewController: vc)
                w.title = url.path
                w.orderFront(nil)
                vc.start(path: url.path)
            }
            else {
                myFiledialog.close()
            }
        })
    }
    
}
