//
//  SearchResultsViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//  
//  JamesonQuave.com
//

import UIKit

class PodcastFeedViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, PodcastManagerProtocol
{
    
    @IBOutlet weak var isLoadingEpisodes: UIActivityIndicatorView!
    let api = PodcastManager()
    let downloader = DownloadManager()
    var podcastEpisodes = [PodcastEpisode]()
    
    var podcastFeed: NSURL?
    var podcastTitle: String?
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        isLoadingEpisodes.startAnimating()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        api.delegate = self
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.delegate = self
        tableView.dataSource = self
    
        title = podcastTitle!
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        isLoadingEpisodes.startAnimating()
        api.feedParser(podcastFeed!)
        
        tableView.reloadData()
    }

    func setValues(feed: NSURL, title: String) {
        self.podcastFeed = feed
        self.podcastTitle = title
    }
    
    @IBOutlet weak var SearchTabBarItem: UITabBarItem!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func didReceiveResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.podcastEpisodes = results as! [(PodcastEpisode)]
            self.isLoadingEpisodes.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Episode"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastEpisodes.count
    }
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! PodcastEpisodeTableViewCell
        
        cell.podcastEpisode = podcastEpisodes[indexPath.row]
        cell.isAccessibilityElement == true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // trigger download
        println("Selected")
        var podcastIndex = tableView.indexPathForSelectedRow()!.row
        var selectedPodcast = self.podcastEpisodes[podcastIndex]
        var downloadURL = selectedPodcast.episodeDownloadURL
        
        downloader.initiateDownload(downloadURL!)
        
    }
}