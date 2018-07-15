//
//  ViewController.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/6/12.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa
import CoreFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var flvFilePathTF: NSTextField!
    @IBOutlet var fileHexTV: NSTextView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var mainOutlineView: NSOutlineView!
    
    var flvParser: QHFlvParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.isHidden = true

        // Do any additional setup after loading the view.
//        if let path = Bundle.main.path(forResource: "dump", ofType: "flv") {
//            flvFilePathTF.stringValue = path
//            flvObject = QHFlvObject(path: path)
//            let bResult = flvObject!.filePaser()
//            if bResult == false {
//                print("文件解析异常")
//            }
//            loadFileData(path: path)
//        }
//
//        mainOutlineView.reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func loadFileData(path: String) {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            let fileData = try Data(contentsOf: fileUrl)
            
            progressIndicator.isHidden = false
            
            var fileHexString = ""
            var asciiString = ""
            
            let totalBytes = fileData.count
            var curPercent = 0.0
            for i in 0..<totalBytes {
                if (i % 16 == 0) {
                    fileHexString += String(format: "0x%08X: ", i)
                    asciiString = ""
                }
                
                let val = fileData[i]
                fileHexString += String(format: "%02X ", val)
                
                if (val >= 0x20 && val <= 0x7f) {
                    asciiString += String(format: "%c", val)
                }
                else {
                    asciiString += "."
                }
                
                if ((i + 1) % 16 == 0) {
                    fileHexString += ("    " + asciiString);
                    fileHexString += "\n"
                }
                
                let newPercent = Double(i) * 100.0 / Double(totalBytes)
                if newPercent - curPercent > 1 {
                    curPercent = newPercent
                    DispatchQueue.main.async {
                        self.progressIndicator.doubleValue = curPercent
                    }
                }
            }
            
            let remain = totalBytes % 16
            
            if remain > 0 {
                for _ in 0..<(16 - remain) {
                    fileHexString += " "
                    asciiString += " "
                }
                fileHexString += ("    " + asciiString);
                fileHexString += "\n"
            }
            
            let attributes: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: NSFont(name: "Courier New", size: 16) as Any,
                NSAttributedStringKey.foregroundColor: NSColor.black]
            
            let content = NSAttributedString(string: fileHexString, attributes: attributes)
            
            DispatchQueue.main.async {
                self.progressIndicator.isHidden = true
                self.fileHexTV.textStorage?.setAttributedString(content)
            }
        } catch  {
            print(error)
        }
        
    }
    
    class func create() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let className = NSStringFromClass(self).components(separatedBy: ".").last!
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: className))
        
        return viewController as! ViewController
    }
    
    func start(path: String) {
        DispatchQueue.main.async {
            self.flvParser = QHFlvParser(path: path)
            let bResult = self.flvParser!.filePaser()
            if bResult == false {
                print("文件解析异常")
                return
            }
            print("onMetaData = { \(self.flvParser!.onMetaDataDic) }")
            self.loadFileData(path: path)
            self.mainOutlineView.reloadData()
        }
    }
    
    private func doAction() {
        if !flvFilePathTF.stringValue.isEmpty {
            progressIndicator.doubleValue = 0.0
            progressIndicator.isHidden = false
            let path = flvFilePathTF.stringValue
            DispatchQueue.global().async {
                self.loadFileData(path: path)
            }
        }
    }
    
    @IBAction func doBtnAction(_ sender: Any) {
//        doAction()
    }
}

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let parser = flvParser {
            return parser.flvBodys.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let parser = flvParser {
            return parser.flvBodys[index]
        }
        return ""
    }
}

extension ViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell : NSTableCellView?
        if let flvBody = item as? QHFlvBody {
            if let cellTemp = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "id"), owner: self) as? NSTableCellView {
                if let tC = tableColumn {
                    if tC.title == "ID" {
                        cellTemp.textField?.stringValue = "\(flvBody.id)"
                    }
                    else if tC.title == "Type" {
                        cellTemp.textField?.stringValue = "\(flvBody.tag.tagType)"
                    }
                    else if tC.title == "Offset" {
                        cellTemp.textField?.stringValue = "\(flvBody.offset)"
                    }
                    else if tC.title == "Size" {
                        cellTemp.textField?.stringValue = "\(flvBody.tag.dataSize)"
                    }
                    else if tC.title == "Timestamp" {
                        cellTemp.textField?.stringValue = "\(flvBody.tag.timestamp)"
                    }
                    else if tC.title == "Format" {
                        cellTemp.textField?.stringValue = "\(flvBody.format)"
                    }
                    else if tC.title == "Ext" {
                        var content = ""
                        if flvBody.tag.tagType == .video, let tagBody = flvBody.tag.tagBody as? QHVideoTag {
//                            if tagBody.codecID == 7 {
                                if tagBody.frameType == 1 {
                                    content = "keyframe"
                                }
                                else if tagBody.frameType == 2 {
                                    content = "interframe"
                                }
//                            }
                        }
                        else if flvBody.tag.tagType == .audio, let tagBody = flvBody.tag.tagBody as? QHAudioTag {
                            content = "\(tagBody.soundRate ?? "") \(tagBody.soundSize ?? "") \(tagBody.soundType ?? "")"
                        }
                        cellTemp.textField?.stringValue = content
                    }
                }
                cell = cellTemp
            }
        }
        return cell
    }
}

