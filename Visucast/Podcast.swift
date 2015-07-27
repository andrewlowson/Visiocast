//
//  Podcast.swift
//  Visiocast
//
//  Created by Andrew Lowson on 26/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import Foundation

class Podcast: NSObject {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var podcastTitle: String = ""
    var podcastArtistName: String = ""
    var podcastArtwork = NSURL(string: "")
    var podcastFeed = NSURL(string: "")
    
    func initWithDetails(title: String, artist: String, artwork: String, feedURL: String) -> Podcast {
        self.podcastTitle = title
        self.podcastArtistName = artist
        self.podcastArtwork = NSURL(string: artwork)
        self.podcastFeed = NSURL(string: feedURL)
        return self
    }
    
    
}
