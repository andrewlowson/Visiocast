//
//  SearchViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var podcasts = [Podcast]()
    var defaultSearchTerm = "https://itunes.apple.com/search?term=podcast+"
    var searchTerm = "https://itunes.apple.com/search?term=podcast+"
   
    
    @IBOutlet weak var podcastTableView: UITableView!

    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.isAccessibilityElement == true
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        podcastTableView.delegate = self
        podcastTableView.dataSource = self
        
        podcastTableView.estimatedRowHeight = podcastTableView.rowHeight
        podcastTableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        
        println("I loaded")
        podcastTableView.reloadData()
        println("I called reload")
    }
    
    
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchText = searchBar.text
        searchTerm = defaultSearchTerm
        podcastSearch(searchText!)
        println("Podcast search should have been called")
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        podcastTableView.reloadData()
        println("I called reload 1 \(searchText)")
    }

    
    var searchText: String? = "" {
        didSet {
            
            podcasts.removeAll()
            searchTerm = defaultSearchTerm
            println("I called reload 2")
        }
    }
    
    func podcastSearch(searchText: String) {
        println("Search was called")
        var search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        searchTerm = defaultSearchTerm + result
        podcastInfo()
    }
    
    func podcastInfo()
    {
        println("Networking was called")
        Alamofire.request(.GET, searchTerm).responseJSON {
            (_, _, jsonDict, _) in
            var json = JSON(jsonDict!)
            // println(json)
            let results = json["results"]
            var collectionName: String?
            var artworkURL: String?
            
            for (index: String, resultJSON: JSON) in results {
                let collectionName = resultJSON["collectionName"].string
                let artistName = resultJSON["artistName"].string
                let artworkURL = resultJSON["artworkUrl600"].string
                let feedURL = resultJSON["feedUrl"].string
                println(self.searchTerm)
                println(collectionName!)
                println(artistName!)
                println(artworkURL!)
                println(feedURL!)
                
                var feedurl = NSURL(string: feedURL!)
                var artworkurl = NSURL(string: artworkURL!)
                var podcast = Podcast()
                podcast.podcastArtistName = artistName!
                podcast.podcastTitle = collectionName!
                podcast.podcastArtwork = artworkurl
                podcast.podcastFeed = feedurl

                self.podcasts.append(podcast)
                println()
                println("\(self.podcasts)")
                self.podcastTableView.reloadData()
                        println("I called reload 3")
            }
            
        }
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Podcast"
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        println("trying to find number of sections")

        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("trying to display number of rows")

        return podcasts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        println("trying to display cells")
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! PodcastTableViewCell
        
        cell.podcast = podcasts[indexPath.row]
        cell.isAccessibilityElement == true
        
        
        return cell
    }

    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let srvc = destination as? SearchResultsViewController {
            if let identifier = segue.identifier {
                if let podcast = podcastTableView.indexPathForSelectedRow()?.row {
                    srvc.podcastFeed = podcasts[podcast].podcastFeed
                    srvc.podcastTitle = podcasts[podcast].podcastTitle
                }
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }


}
