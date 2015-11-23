//
//  PodcastTableViewCell.swift
//  Visiocast
//
//  Created by Andrew Lowson on 27/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    var podcast: Podcast? {
        didSet {
            updateUI()
        }
    }
    @IBOutlet weak var podcastArtworkImageView: UIImageView! {
        didSet {
            podcastArtworkImageView.isAccessibilityElement = true
        }
    }

    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var podcastArtistNameLabel: UILabel!
    
    func updateUI() {
        // main thread main UI
        // background thread for downloads etc
        // reset data before updating
        podcastTitleLabel.text = nil
        podcastArtistNameLabel.text = nil
        podcastArtworkImageView.image = nil
        
        if let podcast = self.podcast {    
            podcastTitleLabel?.text = podcast.podcastTitle
            podcastArtistNameLabel.text = podcast.podcastArtistName

        }
    }
}
