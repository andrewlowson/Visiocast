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

protocol PodcastManagerProtocol {
    func didReceiveResults(results: NSArray)
}

class PodcastManager {
    
    // prefix to search term, used for scraping iTunes directory
    var defaultSearchTerm = "https://itunes.apple.com/search?term=podcast+"
    // Feedly RSS Service URL
    var feedString = "http://cloud.feedly.com/v3/search/feeds/"
    // set up protocol
    var delegate: PodcastManagerProtocol?

    
    /**
    * Method to take a given search term and search the iTunes directory for a matching podcast.
    * Results are then turn into Podcast Objects, put in an Array and passed back to method caller.
    */
    func podcastSearch(searchText: String) -> Array<Podcast> {
        println("Search was called")
        var podcasts = [Podcast]()
        var search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        var searchTerm = defaultSearchTerm + result
        
        println("Networking was called")
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
                    
                    var podcast = Podcast(title: collectionName!, artist: artistName!, artwork: artworkURL!,feedURL: feedURL!)
                    
                    // populate array set delegate result to this array
                    podcasts.append(podcast)
                    self.delegate?.didReceiveResults(podcasts)
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
     * Episode Objecst are then created and all put into an Array passed back to the method caller
     */
    func episodes(feedURL: NSURL, podcast: Podcast) -> Array<PodcastEpisode> {
        
        var episodes: Array<PodcastEpisode> = []
        
        let data = NSData(contentsOfURL: feedURL)
        
        let parser = HTMLParser(data: data, error: nil)
        
        let doc = parser.doc()
        
        let items = doc.findChildTags("item")
        
        for item in items {
            let itemNode = item as! HTMLNode
            
            var title: String? = itemNode.findChildTag("title").contents()
            var subtitle: String? = itemNode.findChildTag("subtitle")?.contents()
            var summary: String? = itemNode.findChildTag("summary")?.contents()
            var publishedDateString: String? = itemNode.findChildTag("pubdate")?.contents()
            var duration: String? = itemNode.findChildTag("duration")?.contents()
            var enclosureURL: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("url")
            var enclosureLengthString: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("length")
            var enclosureLength: Int? = enclosureLengthString?.toInt()
            
            var publishedDate: NSDate?
            
            if publishedDateString != nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
            
                publishedDate = dateFormatter.dateFromString(publishedDateString!)
            }
            if (subtitle == nil) {
                subtitle = ""
            }
            if (summary == nil) {
                summary = ""
            }
            if (publishedDateString == nil) {
                publishedDateString = ""
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
            
            let episode = PodcastEpisode(title: title!,description:  summary!,date:  publishedDate!,duration:  duration!,download:  enclosureURL!,subtitle:  subtitle!,size:  enclosureLength!, podcast: podcast)
            
            episodes.append(episode)
        }
        return episodes
    }
    
    
    
}