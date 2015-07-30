//
//  PodcastManager.swift
//  Visiocast
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation

class PodcastManager {
    class func episodes(feedURL: NSURL) -> Array<PodcastEpisode> {
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
}