//
//  DownloadProgressViewController.swift
//  Visiocast
//
//  Created by Andrew Lowson on 17/08/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class DownloadProgressViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = text
        }
    }
    
    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }
    var timer: NSTimer = NSTimer()
    var downloader = DownloadManager()
    
    override func viewDidLoad() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("updateProgress"), userInfo: nil, repeats: true )
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    func updateProgress() {
        textView.text = downloader.currentProgress()
    }
}
