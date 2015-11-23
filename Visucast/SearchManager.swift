//
//  PodcastManager.swift
//  Visiocast
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//
//  Class initiates and manages the search queries and results for
//  Apple iTunes and Feedly services.  

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
        let search = searchText
        let result = search.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let searchTerm = defaultSearchTerm + result
        do {
            let connected = try Reachability.isConnectedToNetwork()
            if connected {
                // Alamofire is the Networking library used.
                // Give request type (GET), url and then decide what to do with results.
                Alamofire.request(.GET, searchTerm).responseJSON {
        //                (jsonDict) in // the only response we're interested is the dictionary JSON response
        //                var json = JSON(jsonDict!) // turn it into a JSON object
        //                let results = json["results"] // collect the results
        //                var collectionName: String?
        //                var artworkURL: String?
                    response in
                    if response.result.isSuccess {
                        let jsonDict = response.result.value as! NSDictionary
                        let json = JSON(jsonDict)
                        let results = json["results"]
                        var collectionName: String?
                        var artworkURL: String?
                        
                        // for each result, pull out relevant data, create object
        //                    for (index: String, resultJSON: JSON) in results {
                        for (_, resultJSON): (String, JSON) in results {
                            collectionName = resultJSON["collectionName"].string
                            let artistName = resultJSON["artistName"].string
                            artworkURL = resultJSON["artworkUrl600"].string
                            let feedURL = resultJSON["feedUrl"].string
                            
                            if (artworkURL == nil) {
                                artworkURL = resultJSON["artworkUrl100"].string
                            }
                            if collectionName != nil && artistName != nil && artworkURL != nil && feedURL != nil {
                                
                                // if we have what we need, create Podcast object, append it to the array and send it back to the UI
                                let podcast = Podcast(title: collectionName!, artist: artistName!, artwork: artworkURL!,feedURL: feedURL!)
                                
                                // populate array set delegate result to this array
                                podcasts.append(podcast)
                                self.delegate?.didReceiveResults(podcasts)
                            }
                        }
                    }
                }
            }
            else {
                //MARK: TODO - This needs to display to the user, otherwise they won't know why it's not returning a result
                print("No Network Connectivity")
            }
        } catch {
            print("Connection error")
        }
        return podcasts
    }
    
    /**
     * MARK: FeedParser
     * Method to search a podcast RSS and pull out individual episode feeds.
     * results are passed to episode method to parse the feed
     **/
    func feedParser(podcastFeed: NSURL, podcast:Podcast) throws {
        
        let searchTerm = NSURL(string: feedString)
        let connected = try Reachability.isConnectedToNetwork()
        if connected {
            Alamofire.request(
                .GET,
                searchTerm!,
                parameters: ["query": "\(podcastFeed)"],
                encoding: .URL).responseJSON(options: NSJSONReadingOptions()) {
                    response in
                    let jsonValue = JSON(response.data!)
                    
                    if let results = jsonValue["results"].array {
                        for result: JSON in results {
                            // MARK: TODO Sort the array by date to make sure I get it in the right order, example feed Empire Podcast.
                            let feedID = result["feedId"].string
                            var podcastEpisodes = [PodcastEpisode]()
                            let _ = NSURL(string: feedID!)
                            do {
                                podcastEpisodes = try self.episodes(podcastFeed, podcast: podcast)
                                self.delegate?.didReceiveResults(podcastEpisodes)
                            } catch {print("thing")}
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
    func episodes(feedURL: NSURL, podcast: Podcast) throws -> Array<PodcastEpisode> {
        
        var episodes: Array<PodcastEpisode> = []
        var _: UIImage?
        
        let data = NSData(contentsOfURL: feedURL)
        let parser = try HTMLParser(data: data)
        let doc = parser.doc()
        let items = doc.findChildTags("item")
        
        for item in items {
            let itemNode = item as! HTMLNode
            
            // for each item in the response, pull out the information we need for search results
            var title: String? = itemNode.findChildTag("title").contents()
            var subtitle: String? = itemNode.findChildTag("subtitle")?.contents()
            var summary: String? = itemNode.findChildTag("description")?.contents()
            var publishedDateString: String? = itemNode.findChildTag("pubdate")?.contents()
            var duration: String? = itemNode.findChildTag("duration")?.contents()
            var enclosureURL: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("url")
            var enclosureLengthString: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("length")
            var _: String? = itemNode.findChildTag("image")?.getAttributeNamed("href")
            var _: String? = itemNode.findChildTag("guid")?.contents()
            
            var enclosureLength: Int? = Int(enclosureLengthString!)
            
            
            // if any of the items are nil, prepare for that
            if title == nil {
                title = podcast.podcastTitle
                print(feedURL)
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
                print("ERROR NO DOWNLOAD URL FOR \(title)")
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
            
            // create the podcast episode with what we've ended up with and send it back to the view
            
            let episode = PodcastEpisode(title: title!,description:  summary!,date:  publishedDate!,duration:  duration!,download:  enclosureURL!,subtitle:  subtitle!,size:  enclosureLength!, podcast: podcast)
            episodes.append(episode)
        }
        return episodes
    }
    
    // Function to parse all the information for a podcast episode in case the metadata is rubbish.
    func getEpisodeData(feed:NSURL, item: Int, podcast: String) throws -> [String: String]  {
        var episodeData = [String: String]()

        let data = NSData(contentsOfURL: feed)
        let parser = try HTMLParser(data: data!)
        let doc = parser.doc()
        let items = doc.findChildTags("item")

        let itemNode = items[item] as! HTMLNode
        let podcast: String? = podcast
        let title: String? = itemNode.findChildTag("title").contents()
        let summary: String? = itemNode.findChildTag("description")?.contents()
        let _: String? = itemNode.findChildTag("pubdate")?.contents()
        let _: String? = itemNode.findChildTag("duration")?.contents()
        let _: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("url")
        let _: String? = itemNode.findChildTag("enclosure")?.getAttributeNamed("length")
        let imageTag:String? = itemNode.findChildTag("image")?.getAttributeNamed("href")
        let guid: String? = itemNode.findChildTag("guid")?.contents()

        episodeData.updateValue(podcast!, forKey: "podcast")
        episodeData.updateValue(title!, forKey: "title")
        print("Title: \(title!)")
        if summary != nil {
            episodeData.updateValue(summary!, forKey: "description")
        }
        if guid != nil {
            episodeData.updateValue(guid!, forKey: "guid")
        }
        if imageTag != nil {
           // println("\(podcast) \(feed)")
           // println(imageTag)
            episodeData.updateValue(imageTag!, forKey: "artwork")
        } else {
            let image = doc.findChildTag("image") as HTMLNode
                let imageURL: String? = image.findChildTag("url").contents()
             //   println(imageURL!)
                if imageURL != nil {
                    episodeData.updateValue(imageURL!, forKey: "    artwork")
            }
        }
        
        print(episodeData)
        return episodeData
    }
    
    // MARK: RETURN Image as UIImage
    func getImageFromURL (url: NSURL) -> UIImage {
        var image: UIImage! = nil
        let request: NSURLRequest = NSURLRequest(URL: url)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                image = UIImage(data: data!)
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        return image
    }
}