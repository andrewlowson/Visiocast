//
//  DownloadManager.swift
//  Visiocast
//
//  Created by Andrew Lowson on 31/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DownloadManagerProtocol {
    // pass the information to the DownloadsView
}


class DownloadManager {
    
    var fileName: String?
    var finalPath: NSURL?
    var episode: PodcastEpisode?
    
    func initiateDownload(podcastEpisode: PodcastEpisode, downloadURL: NSURL) {
        println("I'm going to start downloading something now")
        episode = podcastEpisode
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        println(destination)
        Alamofire.download(.GET, downloadURL, destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                println(totalBytesRead)
            }
            .response { request, response, _, error in
                println("\(response!)")
                println(self.episode?.episodeTitle)
        }
        // prepare stuff to be sent to the DownloadsView
    }
}

