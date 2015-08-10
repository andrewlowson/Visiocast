//
//  DownloadsTableViewCell.swift
//  Visiocast
//
//  Created by Andrew Lowson on 30/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class DownloadsTableViewCell: UITableViewCell {

    var episode: PodcastEpisode? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var episodeArtworkImageView: UIImageView!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var epsideSummaryLabel: UILabel!
    
    func updateUI() {
            episodeTitleLabel?.text = self.episode!.episodeTitle!
            var podcastURL = self.episode!.podcast?.podcastArtwork!
             
            if let imageData = NSData(contentsOfURL: podcastURL!) { // blocks main thread!
                episodeArtworkImageView?.image = UIImage(data: imageData)
            }

    
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
