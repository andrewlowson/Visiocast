//
//  DownloadProgressViewController.swift
//  Visiocast
//
//  This class is not ucrrently in use 
//  This will be used to display the list of currently downloading shows.
//
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
    @IBOutlet weak var downloadProgressLabel: UILabel!
    
    var episodeTitle: String?
    let defaults = NSUserDefaults.standardUserDefaults()
    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }
    var timer: NSTimer = NSTimer()
    var downloader = DownloadManager()
    
    // if the view returns, reinstate the download progress
    override func viewDidLoad() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("updateProgress"), userInfo: nil, repeats: true )
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
        textView.text = ""
    }
    
    func updateProgress() {
        if episodeTitle != nil {
            if let progress = defaults.objectForKey(episodeTitle!) as? String {
                //textView.text = progress
                downloadProgressLabel.text = progress
            }
        }
    }
}
