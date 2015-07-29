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
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        podcastTableView.delegate = self
        podcastTableView.dataSource = self
        
        podcastTableView.estimatedRowHeight = podcastTableView.rowHeight
        podcastTableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        podcastTableView.reloadData()
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
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        podcastTableView.reloadData()
    }

    
    var searchText: String? = "" {
        didSet {
            podcasts.removeAll()
            searchTerm = defaultSearchTerm
        }
    }
    
    func podcastSearch(searchText: String) {
        println("Search was called")
        var search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        searchTerm = defaultSearchTerm + result
        searchiTunesForPodcast()
    }
    
    func searchiTunesForPodcast()
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
                
                // checking the term was correct
                println(self.searchTerm)

                var podcast = Podcast(title: collectionName!, artist: artistName!, artwork: artworkURL!,feedURL: feedURL!)
                
                self.podcasts.append(podcast)
                self.podcastTableView.reloadData()
            }
            
        }
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Podcast"
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! PodcastTableViewCell
        
        cell.podcast = podcasts[indexPath.row]
        cell.isAccessibilityElement == true
        
        return cell
    }

    
    
    // MARK: - Navigation
    
//    var detailsViewController: DetailsViewController = segue.destinationViewController as! DetailsViewController
//    var albumIndex = appsTableView!.indexPathForSelectedRow()!.row
//    var selectedAlbum = self.albums[albumIndex]
//    detailsViewController.album = selectedAlbum
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var podcastFeed: PodcastFeedViewController = segue.destinationViewController as! PodcastFeedViewController
        var podcastIndex = podcastTableView!.indexPathForSelectedRow()!.row
        
        var selectedPodcast = self.podcasts[podcastIndex]
        println("\(self.podcasts[podcastIndex].podcastTitle)")
        podcastFeed.setValues(selectedPodcast.podcastFeed!, title: selectedPodcast.podcastTitle!)

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }


}























