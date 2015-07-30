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
    var episodeDownloadURL: NSURL?
    var episodeSubtitle: String?
    var episodeDescription: String?
    var episodeDate: NSDate?
    var episodeDuration: String?
    var episodeID: String?
    var episodeSize: Int

    init(title: String, description: String, date: NSDate, duration: String, download: String, subtitle: String, size: Int) {
        self.episodeTitle = title
        self.episodeDownloadURL = NSURL(string: download)
        self.episodeDescription = description
        self.episodeDuration = duration
        self.episodeDate = date
        self.episodeSubtitle = subtitle
        self.episodeSize = size
    }
}