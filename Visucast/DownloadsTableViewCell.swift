//
//  DownloadsTableViewCell.swift
//  Visiocast
//
//  Class for the
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
    
    @IBOutlet weak var podcastNameLabel: UILabel! // show name
    @IBOutlet weak var episodeArtworkImageView: UIImageView! // artowkr, (used to set height of the cell to be uniform
    @IBOutlet weak var episodeTitleLabel: UILabel! // podcast title
    @IBOutlet weak var epsideSummaryLabel: UILabel! //not in use
    
    // set values for all items in the cell
    func updateUI() {
        var artworkURL = self.episode!.podcast?.podcastArtwork!
        podcastNameLabel?.text = self.episode!.podcast!.podcastTitle!
        episodeTitleLabel?.text = self.episode!.episodeTitle!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
