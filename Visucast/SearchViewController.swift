//
//  SearchViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SearchManagerProtocol {
    // MARK: - Instance Variables
    let api = SearchManager() // We will call this to carry out search functions and get arrays of podcasts.
    var podcasts = [Podcast]() // An array of podcast search results to be displayed in the table view
    var podcastArtwork = [NSURL: UIImage]() // An image cache of the artwork so we don't need to download it more than once
    var searchActive : Bool = false
    
    @IBOutlet weak var podcastTableView: UITableView! // Our table containing search results
    
    // setup the searchbar as a delegate and accessible by voiceover
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.isAccessibilityElement = true
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    @IBOutlet weak var waitingForResults: UIActivityIndicatorView!
    
    // MARK: - Initialiser Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.delegate = self
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true // show the network activity spinner in menu
        
        //setup the delegates and datasources
        podcastTableView.delegate = self
        podcastTableView.dataSource = self
        
        // draw the table rows to appropriate height
        podcastTableView.estimatedRowHeight = podcastTableView.rowHeight
        podcastTableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        podcastTableView.reloadData()
    }
    
    // function for the PodcastManagerProtocol
    func didReceiveResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.podcasts = results as! [(Podcast)] // create a podcast array of the results
            self.waitingForResults.stopAnimating() // stop the activity spinner spinner that
            self.podcastTableView.reloadData() // reload the table data
            AudioServicesPlaySystemSound(1054)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, "Search Results Returned")
        }
    }
    
    // MARK: - SearchBar
    // The following four functions handle status of the search bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    // did the user stop typing
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        
    }
    
    // did the user cancel the search and now wants to go do something else?
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // did they initiate search?
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchText = searchBar.text
        podcasts.removeAll()
        podcastTableView.reloadData()
        
        api.podcastSearch(self.searchBar.text!)
        self.waitingForResults.startAnimating() // make activity spinner start spinning
        searchBar.resignFirstResponder() // lower the keyboard
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // text in the Search bar
    var searchText: String? = "" {
        didSet {
            podcasts.removeAll()
            podcastTableView.reloadData()
            api.podcastSearch(self.searchBar.text!)
        }
    }
 
    // MARK: - TableView
    private struct Storyboard {
        static let CellReuseIdentifier = "Podcast"
    }
    
    // we only need one section because we only have one type of result
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // we need the same number of cells as there are podcasts
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    // Function to draw each cell in the view depending on the amount of results
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! PodcastTableViewCell
        
        cell.podcast = podcasts[indexPath.row]
        if let artwork = podcastArtwork[cell.podcast!.podcastArtwork!] {
            cell.podcastArtworkImageView?.image = artwork
        }
        else {
            // The image isn't cached, download the image data
            // We should perform this in a background thread
            let request: NSURLRequest = NSURLRequest(URL: cell.podcast!.podcastArtwork!)
           // let mainQueue = NSOperationQueue.mainQueue()
            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in

//            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let artwork = UIImage(data: data!)
                    // Store the image in to our cache
                    self.podcastArtwork[self.podcasts[indexPath.row].podcastArtwork!] = artwork
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.podcastArtworkImageView?.image = artwork
                    })
                }
                else {
                    print("Error: \(error!.localizedDescription)")
                }
            }
        }
        cell.isAccessibilityElement = true
        return cell
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let podcastFeed: PodcastFeedViewController = segue.destinationViewController as! PodcastFeedViewController
        let podcastIndex = podcastTableView!.indexPathForSelectedRow!.row
        
        let selectedPodcast = self.podcasts[podcastIndex]
        print("\(selectedPodcast.podcastFeed!)")
        podcastFeed.setValues(selectedPodcast.podcastFeed!, podcastTitle: selectedPodcast.podcastTitle!, podcast: selectedPodcast)
    }

}