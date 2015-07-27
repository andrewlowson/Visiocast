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

class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {

    var podcasts = [[Podcast]]()
    var searchTerm = "https://itunes.apple.com/search?term=podcast+"
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    
    var searchActive : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        tableView.delegate = self
        
        println("I loaded")
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchText = searchBar.text
        podcastSearch(searchText!)
        searchBar.resignFirstResponder()
        tableView.reloadData()
        
    }
//    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        if !searchActive {
//                podcastSearch(searchText)
//        }
//        self.tableView.reloadData()
//
//    }
    
    var searchText: String? = "Search for Podcasts" {
        didSet {
            searchBar.text = searchBar.placeholder
            podcasts.removeAll()
            tableView.reloadData()
        }
    }
    
    
    
    func podcastSearch(searchText: String) {
        println("Search was called")
        var search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        searchTerm +=  result
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
                println()
            }
        }
    }
    
    
    // TODO
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
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
