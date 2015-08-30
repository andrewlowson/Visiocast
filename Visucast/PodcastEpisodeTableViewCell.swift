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
  
            // briefly removed due to drawing error when voiceover was on. 
            // need to update this so the error isn't nil and is actually useful.
//            var attrStr = NSAttributedString(
//                data: podcastEpisode.episodeDescription!.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
//                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
//                documentAttributes: nil,
//                error: nil)
            episodeDescription?.text = ""//attrStr
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            var date = formatter.stringFromDate(podcastEpisode.episodeDate!)
            
            // I want to make sure that the duration displayed is in HH:MM:SS
            // Some shows give the duration in a string like that, others are in seconds.
            
            let durationArray = split(podcastEpisode.episodeDuration!) {$0 == ":"} // split the string on :
            if durationArray.count > 1 {
                // if there are more than one elements in the array, then it was already in HH:MM:SS so use that
                var descriptionText = "\(date) · \(podcastEpisode.episodeDuration!)"
                episodeInformation?.text = descriptionText
            } else {
                // otherwise, we need to convert SS to HH:MM:SS
                // this won't work in Swift 2, have to use Int(string)
                if durationArray.count != 0 {
                    if let duration: Int? = durationArray[0].toInt() {
                        if duration != nil {
                            let (h,m,s) = secondsToHoursMinutesSeconds(duration!)
                            var formattedDuration:String?
                            if h > 0 {
                                formattedDuration = "\(h):\(m):\(s)"
                            } else {
                                formattedDuration = "\(m):\(s)"
                            }
                            var descriptionText = "\(date) · \(formattedDuration!)"
                            episodeInformation?.text = descriptionText
                        } else {
                            episodeInformation?.text = "\(date) · \(durationArray[0])"
                        }
                    }
                } else {
                    episodeInformation?.text = ""
                }
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
