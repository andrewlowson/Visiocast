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
    var defaultSearchTerm = "https://itunes.apple.com/search?term=podcast+"
    var delegate: PodcastManagerProtocol?

    func episodes(feedURL: NSURL) -> Array<PodcastEpisode> {
        
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
            if (title == nil ) {
                title = ""
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
            
            println("title: \(title)")
            println("subtitle: \(subtitle)")
            println("summary: \(summary)")
            println("published date: \(publishedDate)")
            println("duration: \(duration)")
            println("enclosure URL: \(enclosureURL)")
            println("enclosure length: \(enclosureLength)")
            
            let episode = PodcastEpisode(title: title!,description:  summary!,date:  publishedDate!,duration:  duration!,download:  enclosureURL!,subtitle:  subtitle!,size:  enclosureLength!)
            
            episodes.append(episode)
        }
        return episodes
    }
    
    func podcastSearch(searchText: String) -> Array<Podcast> {
        println("Search was called")
        var podcasts = [Podcast]()
        var search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        var searchTerm = defaultSearchTerm + result
        
        println("Networking was called")
        println(searchTerm)
        Alamofire.request(.GET, searchTerm).responseJSON {
            (_, _, jsonDict, _) in
            var json = JSON(jsonDict!)
            println(json)
            let results = json["results"]
            var collectionName: String?
            var artworkURL: String?
            
            for (index: String, resultJSON: JSON) in results {
                let collectionName = resultJSON["collectionName"].string
                let artistName = resultJSON["artistName"].string
                let artworkURL = resultJSON["artworkUrl600"].string
                let feedURL = resultJSON["feedUrl"].string
                
                var podcast = Podcast(title: collectionName!, artist: artistName!, artwork: artworkURL!,feedURL: feedURL!)
                
                
                podcasts.append(podcast)
                self.delegate?.didReceiveResults(podcasts)
                println(podcasts)
            }
        }
            return podcasts
        
    }
    
    func feedParser(podcastFeed: NSURL) {
        
        var feedString = "http://cloud.feedly.com/v3/search/feeds/"
        var searchTerm = NSURL(string: feedString)
        
        println("Searching with: \(searchTerm!)")
        println("Podcast Feed: \(podcastFeed)")
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
                        self.getPodcastEpisodes(feedID!, podcastFeed: podcastFeed)
                    }
                }
        }
        
    }
    
    func getPodcastEpisodes(feed: String, podcastFeed: NSURL) {
        println(feed)
        var podcastEpisodes = [PodcastEpisode]()
        var feedURL = NSURL(string: feed)
        podcastEpisodes = episodes(podcastFeed)
        self.delegate?.didReceiveResults(podcastEpisodes)
    }
    
    
    private class func feedlyAPIURL() -> NSURL { return NSURL(string: "http://cloud.feedly.com")! }
    
    private class func feedlySearchURL() -> NSURL {
        return NSURL(string: "\(feedlyAPIURL())/v3/search/feeds")!
    }
    
    func feedlyMixesContentURL(feedID: String) -> NSURL {
        return NSURL(string: "http://cloud.feedly.com/v3/mixes/contents?streamId=\(feedID)")!
    }


}