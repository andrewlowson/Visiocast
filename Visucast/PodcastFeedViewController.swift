//
//  SearchResultsViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PodcastFeedViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate
{
    
    var podcastEpisodes = [PodcastEpisode]()
    
    var podcastFeed: NSURL?
    var podcastTitle: String?
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = tableView.rowHeight
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        println("Podcast Feed for: \(podcastTitle!)")
        title = podcastTitle!
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear " + podcastTitle!)
        println("viewWillAppear \(podcastFeed!)")
        feedParser()
        tableView.reloadData()
    }
//
    func setValues(feed: NSURL, title: String) {
        self.podcastFeed = feed
        self.podcastTitle = title
    }
    
    func feedParser() {
        println("Here goes nothing")
        var feedString = "http://cloud.feedly.com/v3/search/feeds/"
        var searchTerm = NSURL(string: feedString)
        println(feedString)
        println("Searching with: \(searchTerm!)")
        Alamofire.request(
            .GET,
            searchTerm!,
            parameters: ["query": "\(podcastFeed!)"],
            encoding: .URL).responseJSON(options: NSJSONReadingOptions.allZeros) {
                (request: NSURLRequest,
                response: NSHTTPURLResponse?,
                responseJSON: AnyObject?,
                error: NSError?) -> Void in
                
                let jsonValue = JSON(responseJSON!)
                //println(jsonValue)
                if let results = jsonValue["results"].array {
                    for result: JSON in results {
                       // println(result)
                        var feedID = result["feedId"].string
                        println("feedID"+feedID!)
                        self.getPodcastEpisodes(feedID!)
                    }
                }
        }
        
    }
    
    func getPodcastEpisodes(feed: String) {
        println(feed)
        var feedURL = NSURL(string: feed)
        podcastEpisodes = PodcastManager.episodes(podcastFeed!)
        tableView.reloadData()
//        Alamofire.request(
//            .GET,
//            feedlyMixesContentURL(feed),
//            parameters: ["count": 50],
//            encoding: .URL).responseJSON {
//                (request: NSURLRequest,
//                response: NSHTTPURLResponse?,
//                responseJSON: AnyObject?,
//                error: NSError?) -> Void in
//                if responseJSON == nil || error != nil {
//                    return
//                }
//                let jsonValue = JSON(responseJSON!)
//               // println(jsonValue)
//                var articles: Array<PodcastEpisode> = []
//                
//                if let results = jsonValue["items"].array {
//                    for result: JSON in results {
//                        let episodeID = result["id"].string
//                        var title = result["title"].string
//                        var summary = result["summary"]["content"].string
//                        var timestamp = result["published"].int
//                        //var downloadURL = result["enclosure"]["href"].string
//                        var downloadURL = ""
//                        var timeInterval: NSTimeInterval?
//                        
//                        if timestamp != nil {
//                            timeInterval = Double(timestamp!) / 1000.0
//                        }
//
//                        if summary == nil {
//                            summary = ""
//                        }
//                        
//                        var podcastEpisode = PodcastEpisode(title: title!, description: summary!, date: timeInterval!, id: episodeID! ,download: downloadURL)
//                        
//                        self.podcastEpisodes.append(podcastEpisode)
//                        self.tableView.reloadData()
//                    }
//                }
//        }
    }

    private class func feedlyAPIURL() -> NSURL { return NSURL(string: "http://cloud.feedly.com")! }
    
    private class func feedlySearchURL() -> NSURL {
        return NSURL(string: "\(feedlyAPIURL())/v3/search/feeds")!
    }
    
    func feedlyMixesContentURL(feedID: String) -> NSURL {
        return NSURL(string: "http://cloud.feedly.com/v3/mixes/contents?streamId=\(feedID)")!
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

    

}
