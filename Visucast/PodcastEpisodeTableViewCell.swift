//
//  PodcastEpisodeTableViewCell.swift
//  Visiocast
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class PodcastEpisodeTableViewCell: UITableViewCell {

    var podcastEpisode: PodcastEpisode? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeInformation: UILabel!
    @IBOutlet weak var episodeDescription: UILabel!
    
    func updateUI() {
        if let podcastEpisode = self.podcastEpisode {
            episodeTitle?.text = podcastEpisode.episodeTitle!
            
            var attrStr = NSAttributedString(
                data: podcastEpisode.episodeDescription!.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil,
                error: nil)
            episodeDescription?.attributedText = attrStr
            episodeDescription?.font = UIFont.systemFontOfSize(12)
            
            var descriptionText = "\(podcastEpisode.episodeDate!)"
            episodeInformation?.text = "info coming here"
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
