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
import AVFoundation

protocol DownloadManagerProtocol {
    func didReceiveDownload(PodcastEpisode)
}

class DownloadManager {
    
    var fileName: String?
    var finalPath: NSURL?
    var episode: PodcastEpisode?
    var delegate: DownloadManagerProtocol?
    var duplicate: Bool? = false
    
    
    /**
     *
     *
     *
     **/
    func initiateDownload(podcastEpisode: PodcastEpisode, downloadURL: NSURL) {
        episode = podcastEpisode
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("Coding Explorer", forKey: "userNameKey")
        
        var test = episode!.podcast!.podcastFeed!
        
        
        let pathString = "\(downloadURL)"
        let path = split(pathString) {$0 == "/"}
        fileName = path[path.count-1]
        episode!.filePath = fileName
        println("path: \(fileName!)")
        if Reachability.isConnectedToNetwork() {
            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
            println("Destination: \(destination)")
            Alamofire.download(.GET, downloadURL, destination: destination)
                .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                    var inBytes = totalBytesExpectedToRead
                    var inMBytes = Double( (totalBytesExpectedToRead / 1024) / 1024)
                    var soFar = Double(totalBytesRead / 1024) / 1024
                    var percentage = (soFar / inMBytes) * 100
                    var someDoubleFormat = ".3"
                    
                    println("\(percentage.format(someDoubleFormat))% Complete. \(soFar.format(someDoubleFormat))MB of \(inMBytes)MB downloaded.")
                }
                .response { request, response, _, error in
                    println("\(response!)")
                    println(self.episode!.episodeTitle)
                    //self.episode?.filePath =
                   // self.writeMetaData(self.fileName!)
                    self.delegate?.didReceiveDownload(self.episode!)
            }
        }
    }
    
    func writeMetaData(filename: String) {
        var documentsPath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! String
        var fileString = documentsPath+"/"+filename
        var fileURL: NSURL! = NSURL(string: fileString)!
        
        
        
        let item = AVPlayerItem(URL: fileURL)
        
        var stuff = item.asset.metadata
        for item in stuff {
            println(item)
        }
        
//        let newitem: AVMutableMetadataItem
//        newitem.key = AVMetadataKeySpaceCommon
//        newitem.keySpace = AVMetadataKeySpaceCommon
//        
        
        let title = "Title"
        
        let metadataList = item.asset.commonMetadata as! [AVMetadataItem]
        for item in metadataList {
            
        }
        
        
    }
    
    func isDuplicate(fileURL: NSURL) -> Bool {
        
        let urlAsString = "\(fileURL)"
        let path = split(urlAsString) {$0 == "/"}
        let filename = path[path.count-1]
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            
            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
            for file: String in mp3Files {
                println(file + " " + filename)
                if filename == file {
                    self.duplicate = true
                    return self.duplicate!
                }
            }
        }
        return self.duplicate!
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}
