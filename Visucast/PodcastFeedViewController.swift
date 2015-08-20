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

class PodcastFeedViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, PodcastManagerProtocol
{
    
    @IBOutlet weak var isLoadingEpisodes: UIActivityIndicatorView!
    let api = PodcastManager() // used
    let downloader = DownloadManager()
    var podcastEpisodes = [PodcastEpisode]()
    var downloadProgress = [String]()
    var podcastFeedDetails = [String: String]()
    let defaults = NSUserDefaults.standardUserDefaults()

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
    
    // MARK: Download Protocol Handler
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    
    private struct Download {
        static let SegueIdentifier = "Show Download Progress"
        static let DefaultsKey = "DownloadProgressViewController.Progress"
    }
    
    // TODO: Come back to this!
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Download.SegueIdentifier:
                if let dpvc = segue.destinationViewController as? DownloadProgressViewController {
                    if let ppc = dpvc.popoverPresentationController {
                        if tableView.indexPathForSelectedRow() != nil {
                            var podcastIndex: Int? = tableView.indexPathForSelectedRow()!.row
                            if podcastIndex != nil {
                                var selectedPodcast = self.podcastEpisodes[podcastIndex!]
                                var podcastTitle = selectedPodcast.episodeTitle!
                                if !podcastTitle.isEmpty {
                                    dpvc.episodeTitle = podcastTitle
                                }
                            }
                        }
                        ppc.permittedArrowDirections = UIPopoverArrowDirection.Any
                        ppc.delegate = self // this popover delegate alllows you to take control of what's displayed
                    }
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!, traitCollection: UITraitCollection!) -> UIModalPresentationStyle {
        // stop modal box coming up on iPhone
        return UIModalPresentationStyle.None
    }
    
    func didReceiveResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.podcastEpisodes = results as! [(PodcastEpisode)]
            self.isLoadingEpisodes.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: 
    
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
        var podcastIndex = tableView.indexPathForSelectedRow()!.row
        var selectedPodcast = self.podcastEpisodes[podcastIndex]
        var downloadURL = selectedPodcast.episodeDownloadURL
        
        // check to see if user already downloaded the episode, if we don't then download it.
        if !downloader.isDuplicate(downloadURL!) {
            
            // Add the podcast to NSUserDefaults so we can have podcast information in the Player
            var storage = api.getEpisodeData(podcastFeed!, item: podcastIndex, podcast: podcastTitle!)
            
            let pathString = "\(downloadURL!)"
            let path = split(pathString) {$0 == "/"}
            let fileName = path[path.count-1]
            println("Filename: \(fileName)")
            defaults.setObject(storage, forKey: fileName)
            println("Unique Key: \(fileName)")
            println("Value: \(defaults.objectForKey(fileName))")
            
            downloader.initiateDownload(selectedPodcast ,downloadURL: downloadURL!, episodeData: storage)
            episodeTitle = selectedPodcast.episodeTitle!
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("updateProgress"), userInfo: nil, repeats: true )
            
        } else {
            // if we already have the episode display an information box alerting the user to that fact
            let alertController = UIAlertController(title: "Download Error", message: "You have already downloaded this.", preferredStyle: .Alert)
            alertController.isAccessibilityElement = true

            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in } // Set up default OK action for user to dismiss alert
            alertController.addAction(OKAction)
        }
    
    }
    var timer: NSTimer = NSTimer()
    var episodeTitle: String?
    
    func updateProgress() {
        
        if !episodeTitle!.isEmpty {
            if let progress = defaults.objectForKey(episodeTitle!) as? Int {
                self.navigationItem.rightBarButtonItem?.title = "\(progress)%"
                if progress >= 100 {
                    timer.invalidate()
                    self.navigationItem.rightBarButtonItem?.title = "Downloaded"
                }
            }
        }
    }
    
    

}