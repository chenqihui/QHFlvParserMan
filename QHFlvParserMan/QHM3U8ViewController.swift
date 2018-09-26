//
//  QHM3U8ViewController.swift
//  QHFlvParserMan
//
//  Created by Anakin chen on 2018/9/25.
//  Copyright © 2018年 Chen Network Technology. All rights reserved.
//

import Cocoa

class QHM3U8ViewController: NSViewController {
    
    var parser: QHM3U8Parser?

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
            self.parser = QHM3U8Parser(path: path)
            self.parser!.test()
        }
    }
    
}
