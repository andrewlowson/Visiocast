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
    var api = PodcastManager()
    var podcasts = [String]()
    let defaults = NSUserDefaults.standardUserDefaults()
    let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL

    /**
     *
     *
     *
     **/
    func initiateDownload(podcastEpisode: PodcastEpisode, downloadURL: NSURL, storage: [String: String]) {
        episode = podcastEpisode
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("Coding Explorer", forKey: "userNameKey")
        
        var test = episode!.podcast!.podcastFeed!
        
        buildFileArray()
        
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
                    let jsonValue = JSON(response!)
                    let anotherThing = jsonValue["NSHTTPURLResponse"].string
                    println(anotherThing)
                    println(jsonValue)
//                    let url = jsonValue["URL"].string
//                    let statuscode = jsonValue["status code"].int
//                    println("Status Code: \(statuscode)")
//                    println("URL: \(url!)")
//                        let path = split(url!) {$0 == "/"}
//                        let filename = path[path.count-1]
//                        println("Filename: \(filename)")
                    
                        self.delegate?.didReceiveDownload(self.episode!)
//                        self.updateUserDefaults(storage, url: url!, filename: filename)
                    
                    
            }
        }
    }
    
    func updateUserDefaults(storage: [String : String], url: String, filename: String) {
        
        defaults.setObject(storage, forKey: url)
        defaults.setObject(url, forKey: filename)
    }
    
    func writeMetaData(filename: String) {
        // get location and path of downloaded file
        var documentsPath = "\(documentsUrl)"
        var fileString = documentsPath+"/"+filename
        var fileURL: NSURL! = NSURL(string: fileString)!
        
        // get AVAssets and MetaData that currently exist
        let item = AVPlayerItem(URL: fileURL)
        let asset: AVAsset = item.asset
        let metaItems: Int = asset.commonMetadata.count
        println(metaItems)
        
        var metaItem: AVMetadataItem
        var list = [AVMetadataItem]()
        
        // setup new file and newfile path
        var newFileName = filename+"-copy"
        var outputPath = documentsPath+"/"+newFileName
        
        // prepare to create new metadata
        var newArray = [AVMetadataItem]()
        
    }
    
    func isDuplicate(fileURL: NSURL) -> Bool {
        
        let urlAsString = "\(fileURL)"
        let path = split(urlAsString) {$0 == "/"}
        let filename = path[path.count-1]
        
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
    
    func buildFileArray() {
        
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            
            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
            for file: String in mp3Files {
                    podcasts.append(file)
                }
            }
        }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}
