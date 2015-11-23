//
//  PodcastEpisodeTableViewCell.swift
//  Visiocast
//
//  Created by Andrew Lowson on 29/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class PodcastEpisodeTableViewCell: UITableViewCell {

    var accessibilityString: String?
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
            let date = formatter.stringFromDate(podcastEpisode.episodeDate!)
            
            // Make sure that the duration displayed is in HH:MM:SS 
            // Some shows give the duration in a string like that, others are in seconds.
            
            let durationArray = podcastEpisode.episodeDuration!.componentsSeparatedByString(":") // split the string on :
            if durationArray.count > 1 {
                // if there are more than one elements in the array, then it was already in HH:MM:SS so use that
                let descriptionText = "\(date) · \(podcastEpisode.episodeDuration!)"
                episodeInformation?.text = descriptionText
                if durationArray.count > 2 {
                accessibilityString = "\(episodeTitle.text!), \(date), duration, \(durationArray[0]) hours, \(durationArray[1]) minutes and \(durationArray[2]) seconds)"
                } else {
                    accessibilityString = "\(episodeTitle.text!), \(date), duration, \(durationArray[0]) minutes, and \(durationArray[1]) seconds)"
                }
            } else {
                // check to see if duration string has been written HH.MM.SS
                let backupDurationArray = podcastEpisode.episodeDuration!.componentsSeparatedByString(".")
                
                if backupDurationArray.count > 1 {
                    // if there are more than one elements in the array, then it was already in HH:MM:SS so use that
                    let descriptionText = "\(date) · \(podcastEpisode.episodeDuration!)"
                    episodeInformation?.text = descriptionText
                    if backupDurationArray.count > 2 {
                        accessibilityString = "\(episodeTitle.text!), \(date), duration, \(backupDurationArray[0]) hours, \(backupDurationArray[1]) minutes and \(durationArray[2]) seconds)"
                    } else {
                        accessibilityString = "\(episodeTitle.text!), \(date), duration, \(backupDurationArray[0]) minutes, and \(backupDurationArray[1]) seconds)"
                    }
                } else {
                    // otherwise, we need to convert SS to HH:MM:SS
                    // this won't work in Swift 2, have to use Int(string)
                    if durationArray.count != 0 {
                        if let duration: Int? = Int(durationArray[0]) {
                            if duration != nil {
                                var descriptionString: String?
                                let (h,m,s) = secondsToHoursMinutesSeconds(duration!)
                                var formattedDuration:String?
                                if h > 0 {
                                    formattedDuration = "\(h):\(m):\(s)"
                                    descriptionString = "Duration, \(h) hours, \(m) minutes and \(s) seconds"
                                } else {
                                    formattedDuration = "\(m):\(s)"
                                    descriptionString = "Duration, \(m) minutes and \(s) seconds"
                                }
                                let descriptionText = "\(date) · \(formattedDuration!)"
                                episodeInformation?.text = descriptionText
                                
                                episodeInformation.accessibilityValue = "\(date), \(descriptionString!)"
                                accessibilityString = "\(episodeTitle.text!), \(date), \(descriptionString!)"
                                
                            } else {
                                episodeInformation?.text = "\(date) · \(durationArray[0])"
                                episodeInformation.accessibilityValue = "\(episodeTitle.text!), \(date), \(durationArray[0])"
                            }
                        }
                    } else {
                        episodeInformation?.text = ""
                        accessibilityString = episodeTitle.text!
                    }
            }
            }
        }
    }
    func getAccessibilityLabel() -> String {
        if accessibilityString == nil {
            return ""
        } else {
            return accessibilityString!
        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
