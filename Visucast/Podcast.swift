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
 
    var podcastTitle: String! // name of show
    var podcastArtistName: String! // name of artist, e.g. "5by5", "Dan Benjamin and Merlin Man", "NPR" etc
    var podcastArtwork: NSURL! // URL for the artwork file for the show.
    var podcastFeed:    NSURL! // URl for RSS Feed for all the episodes of the show
    
    init(title: String, artist: String, artwork: String, feedURL: String) {
        self.podcastTitle = title
        self.podcastArtistName = artist
        self.podcastArtwork = NSURL(string: artwork)
        self.podcastFeed = NSURL(string: feedURL)
    }
}