//
//  PodcastEpisode.swift
//  Visiocast
//
//  Podcast Episode Object with details on Title, duration, file size and file location
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class PodcastEpisode: NSObject {
    
    var episodeTitle: String?
    var episodeDownloadURL: NSURL?
    var episodeSubtitle: String?
    var episodeDescription: String?
    var episodeDate: NSDate?
    var episodeDuration: String?
    var episodeID: String?
    var episodeSize: Int
    var podcast: Podcast?
    var filePath: String?
    var artwork: UIImage?

//    init(title: String, description: String, date: NSDate,
//        duration: String, download: String, subtitle: String, size: Int, podcast: Podcast, artwork: String)
    init(title: String, description: String, date: NSDate,
        duration: String, download: String, subtitle: String, size: Int, podcast: Podcast)

    {
        self.episodeTitle = title
        self.episodeDownloadURL = NSURL(string: download)
        self.episodeDescription = description
        self.episodeDuration = duration
        self.episodeDate = date
        self.episodeSubtitle = subtitle
        self.episodeSize = size
        self.podcast = podcast
        
        
//        if artwork == "" {
//            var image = UIImage(named: "glasgowLogo")
//            self.artwork = image
//        } else {
//            var image = UIImage(data: NSData(contentsOfURL: NSURL(string: artwork)!)!)
//            self.artwork = image
//        }
//        
        
    }
}