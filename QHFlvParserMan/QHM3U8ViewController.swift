//
//  QHM3U8ViewController.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/25.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHM3U8ViewController: NSViewController {
    
    @IBOutlet weak var mainOutlineView: NSOutlineView!
    
    var m3uParser: QHM3U8Parser?
    var tsParser: QHTSParser?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    class func create() -> QHM3U8ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let className = NSStringFromClass(self).components(separatedBy: ".").last!
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: className))
        
        return viewController as! QHM3U8ViewController
    }
    
    func start(path: String) {
        DispatchQueue.main.async {
            self.tsParser = QHTSParser(path: path)
            self.tsParser?.parser()
            self.mainOutlineView.reloadData()
        }
    }
    
}

extension QHM3U8ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let parser = tsParser {
            return parser.tsArr.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let parser = tsParser {
            return parser.tsArr[index]
        }
        return ""
    }
}

var idx = 0

extension QHM3U8ViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell : NSTableCellView?
        if let ts = item as? QHTS {
            if let cellTemp = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Row"), owner: self) as? NSTableCellView {
                if let tC = tableColumn {
                    cellTemp.textField?.stringValue = ""
                    if tC.title == "Row" {
                        cellTemp.textField?.stringValue = "\(ts.id)"
                    }
                    else if tC.title == "Type" {
                        cellTemp.textField?.stringValue = "\(ts.type)"
                    }
                    else if tC.title == "PID" {
                        if let head = ts.head {
                            cellTemp.textField?.stringValue = "\(head.pid)"
                        }
                    }
                    else if tC.title == "StreamType" {
                        if let parser = tsParser, let head = ts.head {
                            var streamType = ""
                            if parser.h264PIDs.contains(head.pid) {
                                streamType = "h264"
                            }
                            else if parser.ACCPIDs.contains(head.pid) {
                                streamType = "acc"
                            }
                            else if parser.MP3PIDs.contains(head.pid) {
                                streamType = "mp3"
                            }
                            cellTemp.textField?.stringValue = "\(streamType)"
                        }
                    }
                    else if tC.title == "PTS" {
                        if let head = ts.payload?.head {
                            cellTemp.textField?.stringValue = "\(head.pts)"
                        }
                    }
                    else if tC.title == "DTS" {
                        if let head = ts.payload?.head {
                            cellTemp.textField?.stringValue = "\(head.dts)"
                        }
                    }
                    else if tC.title == "Other" {
                        cellTemp.textField?.stringValue = ""
                    }
                }
                cell = cellTemp
            }
        }
        return cell
    }
}
