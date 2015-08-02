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
    func didReceiveDownload(PodcastEpisode)
}


class DownloadManager {
    
    var fileName: String?
    var finalPath: NSURL?
    var episode: PodcastEpisode?
    var delegate: DownloadManagerProtocol?
    
    func initiateDownload(podcastEpisode: PodcastEpisode, downloadURL: NSURL) {
        println("I'm going to start downloading something now")
        episode = podcastEpisode
        let pathString = "\(downloadURL)"
        
        let path = split(pathString) {$0 == "/"}
        fileName = path[path.count-1]
        episode!.filePath = fileName
        println("path: \(fileName!)") // [foo, bar, baz]
        
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        println("Destination: \(destination)")
        Alamofire.download(.GET, downloadURL, destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                var inBytes = totalBytesExpectedToRead
                var inMBytes = Double( (totalBytesExpectedToRead / 1024) / 1024)
                
                var soFar = Double(totalBytesRead / 1024) / 1024
                var percentage = (soFar / inMBytes) * 100
               // println("\(percentage)% Complete. \(soFar)MB of \(inMBytes)MB downloaded.")
            }
            .response { request, response, _, error in
                println("\(response!)")
                println(self.episode!.episodeTitle)
                //self.episode?.filePath =
                self.delegate?.didReceiveDownload(self.episode!)
        }
    }
}

