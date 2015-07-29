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
//        http://feeds.5by5.tv/b2w
//        http://cloud.feedly.com//v3/search/feeds/
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
                
                if let results = jsonValue["results"].array {
                    for result: JSON in results {
                        var feedID = result["feedId"].string
                        println(feedID!)
                        self.getPodcastEpisodes(feedID!)
//                        podcast = PodcastEpisode()
//                        var podcast.episodeTitle = result["title"].string
//                        var summary = result["summary"]["content"].string
//                        var imageURL = result["visual"]["url"].URL
//                        podcast = PodcastEpisode()
//                        podcastEpisodes.append()
                    }
                }
        }
        
    }
    
    func getPodcastEpisodes(feed: String) {
        Alamofire.request(
            .GET,
            feedlyMixesContentURL(feed),
            parameters: ["count": 20, "hours": 15],
            encoding: .URL).responseJSON(options: NSJSONReadingOptions.allZeros) {
                (request: NSURLRequest,
                response: NSHTTPURLResponse?,
                responseJSON: AnyObject?,
                error: NSError?) -> Void in
                if responseJSON == nil || error != nil {
                    return
                }
                
                let jsonValue = JSON(responseJSON!)
                println(jsonValue)
                var articles: Array<PodcastEpisode> = []
                
                if let results = jsonValue["items"].array {
                    for result: JSON in results {
                        let episodeID = result["id"].string
                        var title = result["title"].string
                        var summary = result["summary"]["content"].string
                        var timestamp = result["published"].int
                        //var downloadURL = result["enclosure"]["href"].string
                        var downloadURL = ""
                        var timeInterval: NSTimeInterval?
                        
                        if timestamp != nil {
                            timeInterval = Double(timestamp!) / 1000.0
                        }

                        var podcastEpisode = PodcastEpisode(title: title!, description: summary!, date: timeInterval!, id: episodeID! ,download: downloadURL)
                        
                        self.podcastEpisodes.append(podcastEpisode)
                        self.tableView.reloadData()
                        
                        //Cleans up strings if necessary
                        
//                        let article = FeedlyArticle(articleID: articleID!, title: title!)
//                        article.summary = summary
//                        article.imageURL = imageURL
//                        article.articleURL = articleURL
//                        article.engagement = engagement
//                        article.engagementRate = engagementRate
//                        article.publishedTimeInterval = timeInterval
                        
                  //      articles.append(article)
                    }
                }
                
//                articles.sort({
//                    (firstArticle: FeedlyArticle, secondArticle: FeedlyArticle) -> Bool in
//                    
//                    if firstArticle.engagement == nil || firstArticle.age() == nil
//                        || secondArticle.engagement == nil || secondArticle.age() == nil {
//                            return true
//                    }
//                    
//                    var firstArticleEngagementOverTime = Double(firstArticle.engagement!) / firstArticle.age()!
//                    var secondArticleEngagementOverTime = Double(secondArticle.engagement!) / secondArticle.age()!
//                    
//                    return firstArticleEngagementOverTime > secondArticleEngagementOverTime
//                })
//                
//                while articles.count > articleCount {
//                    articles.removeLast()
//                }
//                
//                completion(articles: articles, error: nil)
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
