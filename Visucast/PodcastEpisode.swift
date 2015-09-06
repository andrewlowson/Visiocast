//
//  PodcastEpisode.swift
//  Visiocast
//
//  Podcast Episode Object with details on Title, duration, file size and file location
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//
import Foundation

class PodcastEpisode: NSObject {
    
    var episodeTitle: String? // Title of particular episode
    var episodeDownloadURL: NSURL?
    var episodeSubtitle: String? // Brief summary of episode
    var episodeDescription: String? // longer summary of show
    var episodeDate: NSDate? // release date
    var episodeDuration: String? // duration in seconds
    var episodeID: String? // Unique ID for the file (will be used when subscriptions are added)
    var episodeSize: Int // size of file in bytes
    var podcast: Podcast? // Podcast Object associated with episode

    // constructor to assign instance variables when PodcastEpisode object is instantiated
    init(title: String, description: String, date: NSDate, duration: String, download: String, subtitle: String, size: Int, podcast: Podcast) {
        self.episodeTitle = title
        self.episodeDownloadURL = NSURL(string: download)
        self.episodeDescription = description
        self.episodeDuration = duration
        self.episodeDate = date
        self.episodeSubtitle = subtitle
        self.episodeSize = size
        self.podcast = podcast
    }
}