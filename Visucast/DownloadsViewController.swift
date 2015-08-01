//
//  DownloadsViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , DownloadManagerProtocol, PodcastManagerProtocol {

    var podcasts = [Podcast]()
    
    @IBOutlet weak var episodesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let api = DownloadManager()
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveResults(results: NSArray) {
        //
    }
    
    @IBOutlet weak var downloadsTableView: UITableView!

    @IBOutlet weak var DownloadsTabBarItem: UITabBarItem!
    
    func addPodcast(podcast: PodcastEpisode, downloadURL: NSURL) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Episode"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! DownloadsTableViewCell
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension NSFileManager {
    func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        
        return documentsDirectory as! String
    }
}