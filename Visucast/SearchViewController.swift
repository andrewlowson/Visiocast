//
//  SearchViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PodcastManagerProtocol {

    var podcasts = [Podcast]()
    
    // Dictionary with String, UIImage
    var podcastArtwork = [NSURL: UIImage]()
    
    let api = PodcastManager()
    
    @IBOutlet weak var podcastTableView: UITableView!

    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.isAccessibilityElement == true
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    
    var searchActive : Bool = false
    
    @IBOutlet weak var waitingForResults: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        podcastTableView.delegate = self
        podcastTableView.dataSource = self
        
        podcastTableView.estimatedRowHeight = podcastTableView.rowHeight
        podcastTableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        podcastTableView.reloadData()
    }
    
    func didReceiveResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.podcasts = results as! [(Podcast)]
            self.waitingForResults.stopAnimating()
            self.podcastTableView.reloadData()
        }
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
        podcasts.removeAll()
        podcastTableView.reloadData()
        
        api.podcastSearch(self.searchBar.text)
        self.waitingForResults.startAnimating()
        println("back to search")
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
    }
    
    var searchText: String? = "" {
        didSet {
            podcasts.removeAll()
            podcastTableView.reloadData()
            api.podcastSearch(self.searchBar.text)
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
        
        //  This imagecaching block was suggested on JamesonQuave.com, it dramatically improves scrolling performance
        if let artwork = podcastArtwork[self.podcasts[indexPath.row].podcastArtwork!] {
            cell.podcastArtworkImageView?.image = artwork
        }
        else {
            // The image isn't cached, download the image data
            // We should perform this in a background thread
            let request: NSURLRequest = NSURLRequest(URL: cell.podcast!.podcastArtwork!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data)
                    // Store the image in to our cache
                    self.podcastArtwork[self.podcasts[indexPath.row].podcastArtwork!] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.podcastArtworkImageView?.image = image
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        

        
        cell.isAccessibilityElement == true
        
        return cell
    }

    
    
    // MARK: - Navigation
    
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