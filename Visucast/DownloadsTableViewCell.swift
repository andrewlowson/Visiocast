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
        var artworkURL = self.episode!.podcast?.podcastArtwork!
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
