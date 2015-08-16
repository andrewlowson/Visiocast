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
        
        let request: NSURLRequest = NSURLRequest(URL: artworkURL!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                println("I tried to create the image")
                // Convert the downloaded data in to a UIImage object
                let artwork = UIImage(data: data)
                
                dispatch_async(dispatch_get_main_queue(), {
                    episodeArtworkImageView?.image = artwork
                })
            } else {
                println("Error: \(error.localizedDescription)" )
            }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
