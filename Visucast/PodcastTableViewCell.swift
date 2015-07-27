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

    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var podcastArtistNameLabel: UILabel!
    @IBOutlet weak var podcastArtworkImageView: UIImageView!
    
    func updateUI() {
        
        // reset data before updating
        podcastTitleLabel.text = nil
        podcastArtistNameLabel.text = nil
        podcastArtworkImageView.image = nil
        
        if let podcast = self.podcast {
            
            podcastTitleLabel?.text = podcast.podcastTitle
            podcastArtistNameLabel.text = podcast.podcastArtistName

            if let artworkURL = podcast.podcastArtwork {
                if let imageData = NSData(contentsOfURL: artworkURL) {
                    // This blocks the main thread...fix...
                    podcastArtworkImageView?.image = UIImage(data: imageData)
                }
            }
            

        }
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
