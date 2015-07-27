//
//  PodcastTableViewCell.swift
//  Visiocast
//
//  Created by Andrew Lowson on 27/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    var search: SearchRequest? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var podcastArtistNameLabel: UILabel!
    @IBOutlet weak var podcastArtworkImageView: UIImageView!
    
    func updateUI() {
       podcastTitleLabel.text = nil
       podcastArtistNameLabel.text = nil
       podcastArtworkImageView.image = nil
        
        
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
