//
//  QHMP4ViewController.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/7/29.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHMP4ViewController: NSViewController {
    
    @IBOutlet weak var mainOutlineView: NSOutlineView!
    @IBOutlet var contentTV: NSTextView!
    
    var parser: QHMP4Parser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //        if let path = Bundle.main.path(forResource: "good", ofType: "mp4") {
        //            let test = QHMP4Parser(path: path)
        //            test.test()
        //        }
    }
    
    class func create() -> QHMP4ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let className = NSStringFromClass(self).components(separatedBy: ".").last!
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: className))
        
        return viewController as! QHMP4ViewController
    }
    
    func start(path: String) {
        DispatchQueue.main.async {
            self.parser = QHMP4Parser(path: path)
            self.parser!.test()
            self.mainOutlineView.reloadData()
//            self.mainOutlineView.expandItem(nil, expandChildren: true)
        }
    }
    
}

extension QHMP4ViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let box = item as? QHMP4Box {
            if let boxs = box.boxs {
                return boxs.count
            }
        }
        if let boxs = parser?.MP4boxs {
            return boxs.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let box = item as? QHMP4Box {
            if let boxs = box.boxs {
                return boxs[index]
            }
            return box
        }
        if let boxs = parser?.MP4boxs {
            return boxs[index]
        }
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let box = item as? QHMP4Box {
            if let boxs = box.boxs, boxs.count > 0 {
                return true
            }
        }
        return false
    }
}

extension QHMP4ViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell: NSTableCellView?
        if let box = item as? QHMP4Box {
            cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
            cell?.textField?.stringValue = box.header.type.rawValue
        }
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let box = item as? QHMP4Box {
            self.contentTV.string = box.description
        }
        return false
    }
    
}
