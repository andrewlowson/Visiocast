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

class PodcastFeedViewController: UITableViewController, NSXMLParserDelegate
{
    let appleProducts = ["iMac", "iPhone", "Apple Watch", "iPod", "iPad", "AppleTV", "Mac Pro"]
    var podcastFeed: NSURL?
    var podcastTitle: String?
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        println("Podcast Feed Page")
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        println("Podcast Feed for: \(podcastTitle!)")
        feedParser()
        
        
        
        //refresh()
//        self.resultSearchController = UISearchController(searchResultsController: nil)
//        //self.resultSearchController.searchResultsUpdater = self
//        
//        self.resultSearchController.dimsBackgroundDuringPresentation = false
//        self.resultSearchController.searchBar.sizeToFit()
//        
//        self.tableView.tableHeaderView = self.resultSearchController.searchBar
//        
//        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear " + podcastTitle!)
        println("viewWillAppear \(podcastFeed!)")
    }
    
    
    func feedParser() {
        println("Here goes nothing")
        Alamofire.request(.GET, podcastFeed!).responsePropertyList() {
            (_, _, jsonDict, _) in
            println(jsonDict)
//            let results = json["results"]
//            var collectionName: String?
//            var artworkURL: String?
//            
//            for (index: String, resultJSON: JSON) in results {
//                let collectionName = resultJSON["collectionName"].string
//                let artistName = resultJSON["artistName"].string
//                let artworkURL = resultJSON["artworkUrl600"].string
//                let feedURL = resultJSON["feedUrl"].string
//                
//                // checking the term was correct
//                println(self.searchTerm)
//                
//                var podcast = Podcast(title: collectionName!, artist: artistName!, artwork: artworkURL!,feedURL: feedURL!)
//                
//                self.podcasts.append(podcast)
//                self.podcastTableView.reloadData()
//            }
//            
        }
        
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

}
