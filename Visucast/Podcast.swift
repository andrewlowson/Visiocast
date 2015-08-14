//
//  Podcast.swift
//  Visiocast
//
//  Podcast Object with Title, Artwork and RSS feed URL.
//
//  Created by Andrew Lowson on 26/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation

class Podcast {
    
    var podcastTitle: String!
    var podcastArtistName: String!
    var podcastArtwork: NSURL!
    var podcastFeed:    NSURL!
    
    var episodes = [PodcastEpisode]()
    
    init(title: String, artist: String, artwork: String, feedURL: String) {
        self.podcastTitle = title
        self.podcastArtistName = artist
        self.podcastArtwork = NSURL(string: artwork)
        self.podcastFeed = NSURL(string: feedURL)
    }
    
}
