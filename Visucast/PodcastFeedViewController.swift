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
        println("Podcast Feed Page")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        println("Podcast Feed for: \(podcastTitle!)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear " + podcastTitle!)
        println("viewWillAppear \(podcastFeed!)")
        feedParser()
    }
//
    func setValues(feed: NSURL, title: String) {
        self.podcastFeed = feed
        self.podcastTitle = title
    }
    
    func feedParser() {
        println("Here goes nothing")
        var feedString = "http://cloud.feedly.com/v3/feeds/\(podcastFeed!)"
        var searchTerm = NSURL(string: feedString)
        println(feedString)
        println("Searching with: \(searchTerm!)")
        Alamofire.request(
            .GET,
            searchTerm!,
            encoding: .URL).responseJSON(options: NSJSONReadingOptions.allZeros) {
                (request: NSURLRequest,
                response: NSHTTPURLResponse?,
                responseJSON: AnyObject?,
                error: NSError?) -> Void in
                
                let jsonValue = JSON(responseJSON!)
                println(responseJSON)

                println(jsonValue)
//                if let results = jsonValue["items"].array {
//                    for result: JSON in results {
//                        podcast = PodcastEpisode()
//                        var podcast.episodeTitle = result["title"].string
//                        var summary = result["summary"]["content"].string
//                        var imageURL = result["visual"]["url"].URL
//                        podcast = PodcastEpisode()
//                        podcastEpisodes.append()
//                    }
//                }
        }
        
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
