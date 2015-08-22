//
//  PodcastManager.swift
//  Visiocast
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

protocol SearchManagerProtocol {
    func didReceiveResults(results: NSArray)
}

class SearchManager {
    
    // Constants and Instance Variables
    let defaultSearchTerm = "https://itunes.apple.com/search?term=podcast+"     // prefix to search term, used for scraping iTunes directory
    let feedString = "http://cloud.feedly.com/v3/search/feeds/"     // Feedly RSS Service URL
    let defaults = NSUserDefaults.standardUserDefaults() // persistent storage setup
    var delegate: SearchManagerProtocol?     // set up protocol
    

    
    /**
    * Method to take a given search term and search the iTunes directory for a matching podcast.
    * Results are then turn into Podcast Objects, put in an Array and passed back to method caller.
    */
    func podcastSearch(searchText: String) -> Array<Podcast> {
        var podcasts = [Podcast]()
        var search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        var searchTerm = defaultSearchTerm + result
        
        if Reachability.isConnectedToNetwork() {
            // Alamofire is the Networking library used.
            // Give request type (GET), url and then decide what to do with results.
            Alamofire.request(.GET, searchTerm).responseJSON {
                (_, _, jsonDict, _) in
                var json = JSON(jsonDict!)
                let results = json["results"]
                var collectionName: String?
                var artworkURL: String?
                
                // for each result, pull out relevant data, create object
                for (index: String, resultJSON: JSON) in results {
                    let collectionName = resultJSON["collectionName"].string
                    let artistName = resultJSON["artistName"].string
                    var artworkURL = resultJSON["artworkUrl600"].string
                    var feedURL = resultJSON["feedUrl"].string

                    if (artworkURL == nil) {
                        var artworkURL = resultJSON["artworkUrl100"].string
                    }
                    if collectionName != nil && artistName != nil && artworkURL != nil && feedURL != nil {
                        var podcast = Podcast(title: collectionName!, artist: artistName!, artwork: artworkURL!,feedURL: feedURL!)
                        
                        // populate array set delegate result to this array
                        podcasts.append(podcast)
                        self.delegate?.didReceiveResults(podcasts)
                    }
                }
            }
        }
        else {
            println("No Network Connectivity")
        }
        return podcasts
    }
    
    /**
    * Method to search a podcast RSS and pull out individual episode feeds.
    * results are passed to episode method to parse the feed
    */
    func feedParser(podcastFeed: NSURL, podcast:Podcast) {
        
        var searchTerm = NSURL(string: feedString)
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(
                .GET,
                searchTerm!,
                parameters: ["query": "\(podcastFeed)"],
                encoding: .URL).responseJSON(options: NSJSONReadingOptions.allZeros) {
                    (request: NSURLRequest,
                    response: NSHTTPURLResponse?,
                    responseJSON: AnyObject?,
                    error: NSError?) -> Void in
                    
                    let jsonValue = JSON(responseJSON!)
                    if let results = jsonValue["results"].array {
                        for result: JSON in results {
                            var feedID = result["feedId"].string
                            var podcastEpisodes = [PodcastEpisode]()
                            var feedURL = NSURL(string: feedID!)
                            podcastEpisodes = self.episodes(podcastFeed, podcast: podcast)
                            self.delegate?.didReceiveResults(podcastEpisodes)
                        }
                    }
            }
        } else {
        }
    }
    
    /**
     * Method to parse a podcast RSS and pull out individual episodes.
     * Episode Objects are then created and all put into an Array passed back to the method caller
     */
    func episodes(feedURL: NSURL, podcast: Podcast) -> Array<PodcastEpisode> {
        
        var episodes: Array<PodcastEpisode> = []
        var podcastArtwork: UIImage?
        
        let data = NSData(contentsOfURL: feedURL)
        let parser = HTMLParser(data: data, error: nil)
        let doc = parser.doc()
        let items = doc.findChildTags("item")
        
        for item in items {
            let itemNode = item as! HTMLNode
            
            var title: String? = itemNode.findChildTag("title").contents()
            var subtitle: String? = itemNode.findChildTag("subtitle")?.contents()
            var summary: String? = itemNode.findChildTag("description")?.contents()
            var publishedDateString: String? = itemNode.findChildTag("pubdate")?.contents()
            var duration: String? = itemNode.findChildTag("duration")?.contents()
            var enclosureURL: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("url")
            var enclosureLengthString: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("length")
            var imageTag:String? = itemNode.findChildTag("image")?.getAttributeNamed("href")
            var guid: String? = itemNode.findChildTag("guid")?.contents()
            
            var enclosureLength: Int? = enclosureLengthString?.toInt()
            
            if title == nil {
                title = podcast.podcastTitle
                println(feedURL)
            }
            if (subtitle == nil) {
                subtitle = ""
            }
            if (summary == nil) {
                summary = ""
            }
            if (duration == nil) {  
                duration = ""
            } 
            if (enclosureURL == nil) {
                println("ERROR NO DOWNLOAD URL FOR \(title)")
                enclosureURL = ""
            }
            if (enclosureLengthString == nil) {
                enclosureLengthString = ""
            }
            if (enclosureLength == nil) {
                enclosureLength = 0
            }
            
            var publishedDate: NSDate?
            if (publishedDateString == nil) {
                publishedDateString = ""
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            publishedDate = dateFormatter.dateFromString(publishedDateString!)
            
            let episode = PodcastEpisode(title: title!,description:  summary!,date:  publishedDate!,duration:  duration!,download:  enclosureURL!,subtitle:  subtitle!,size:  enclosureLength!, podcast: podcast)
            episodes.append(episode)
        }
        return episodes
    }
    
    func getEpisodeData(feed:NSURL, item: Int, podcast: String) -> [String: String] {
        var episodeData = [String: String]()

        
        let data = NSData(contentsOfURL: feed)
        let parser = HTMLParser(data: data, error: nil)
        let doc = parser.doc()
        let items = doc.findChildTags("item")

        var itemNode = items[item] as! HTMLNode
        var podcast: String? = podcast
        var title: String? = itemNode.findChildTag("title").contents()
        var summary: String? = itemNode.findChildTag("description")?.contents()
        var publishedDateString: String? = itemNode.findChildTag("pubdate")?.contents()
        var duration: String? = itemNode.findChildTag("duration")?.contents()
        var enclosureURL: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("url")
        var enclosureLengthString: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("length")
        var imageTag:String? = itemNode.findChildTag("image")?.getAttributeNamed("href")
        var guid: String? = itemNode.findChildTag("guid")?.contents()

        episodeData.updateValue(podcast!, forKey: "podcast")
        episodeData.updateValue(title!, forKey: "title")
        println(title!)
        if summary != nil {
            episodeData.updateValue(summary!, forKey: "description")
        }
        if guid != nil {
            episodeData.updateValue(guid!, forKey: "guid")
        }
        if (imageTag != nil) {
            println("\(podcast) \(feed)")
            println(imageTag)
            episodeData.updateValue(imageTag!, forKey: "artwork")
        } else {
            var image = doc.findChildTag("image") as HTMLNode
                var imageURL: String? = image.findChildTag("url").contents()
                println(imageURL!)
                if imageURL != nil {
                    episodeData.updateValue(imageURL!, forKey: "    artwork")
            }
        }
        
        println(episodeData)
        return episodeData
    }
    
    func getImageFromURL (url: NSURL) -> UIImage {
        var image: UIImage! = nil
        let request: NSURLRequest = NSURLRequest(URL: url)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                image = UIImage(data: data)
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        return image
    }
}