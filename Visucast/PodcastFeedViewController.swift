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
    var podcastFeedDetails = [String: String]()
    
    var podcast: Podcast?
    var podcastFeed: NSURL?
    var podcastTitle: String?
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true // activate the Network spinner in the menubar
        isLoadingEpisodes.startAnimating() // activity spinner to show user that we're polling the feed for results
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension // set the heights for the tableview cells
        
        api.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
    
        title = podcastTitle! //set view title to be the name of the podcast the user selected
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        isLoadingEpisodes.startAnimating()
        api.feedParser(podcastFeed!, podcast: podcast!)
        
        tableView.reloadData()
    }

    func setValues(podcastFeed: NSURL, podcastTitle: String, podcast: Podcast) {
        self.podcast = podcast
        self.podcastFeed = podcastFeed
        self.podcastTitle = podcastTitle
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
        return podcastEpisodes.count // we want one cell for each podcast episode we get in the feed
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
        
        // check to see if user already downloaded the episode, if we don't then download it.
        if !downloader.isDuplicate(downloadURL!) {
            downloader.initiateDownload(selectedPodcast ,downloadURL: downloadURL!)
        } else {
            // if we already have the episode display an information box alerting the user to that fact
            let alertController = UIAlertController(title: "Download Error", message: "You have already downloaded this.", preferredStyle: .Alert)
            alertController.isAccessibilityElement = true

            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in } // Set up default OK action for user to dismiss alert
            alertController.addAction(OKAction)
        }
        
    }
}