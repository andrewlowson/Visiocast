//
//  PodcastEpisode.swift
//  Visiocast
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class PodcastEpisode: NSObject {
    
    var episodeTitle: String?
    //var episodeDownloadURL: NSURL?
    var episodeDescription: String?
    var episodeDate: NSTimeInterval?
    var episodeDuration: String?
    var episodeID: String?
    
    
    init(title: String, description: String, date: NSTimeInterval, id: String, download: String) {
        self.episodeTitle = title
        //self.episodeDownloadURL = NSURL(string: download)
        self.episodeDescription = description
        self.episodeDate = date
        self.episodeID = id
    }
    
}
