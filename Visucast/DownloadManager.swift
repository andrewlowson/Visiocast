//
//  DownloadManager.swift
//  Visiocast
//
//  Created by Andrew Lowson on 31/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import AVFoundation
import UIKit

protocol DownloadManagerProtocol {
    func didReceiveDownload(_: PodcastEpisode)
}

class DownloadManager {
    
    var fileName: String?
    var finalPath: NSURL?
    var episode: PodcastEpisode?
    var delegate: DownloadManagerProtocol?
    var duplicate: Bool? = false
    var api = SearchManager()
    var progress: String = "Nothing Currently Downloading"
    var podcasts = [String]()
    let defaults = NSUserDefaults.standardUserDefaults()
    let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL?

    /**
     * Main function to download an episode of a podcast.
     * Prints out the progress state as a percentage and as a total
     * 
     **/
    func initiateDownload(podcastEpisode: PodcastEpisode, downloadURL: NSURL, episodeData: [String: String]) throws {
        episode = podcastEpisode
        let connected = try Reachability.isConnectedToNetwork()
            if connected {
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                // start the download off the main thread so UI still remains responsive
                _ = 0
                let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
                Alamofire.download(.GET, downloadURL, destination: destination)
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        _ = totalBytesExpectedToRead
                        let inMBytes = Double( (totalBytesExpectedToRead / 1024) / 1024)
                        let soFar = Double(totalBytesRead / 1024) / 1024
                        let percentage = (soFar / inMBytes) * 100
                        if percentage <= 100 {
                            let currentProgress = percentage
                            self.defaults.setObject(currentProgress, forKey: podcastEpisode.episodeTitle!)
                        } else {
                            let currentProgress = percentage
                            self.defaults.setObject(currentProgress, forKey: podcastEpisode.episodeTitle!)
                        }
                    }
                    //.responseJSON { request, response, jsonDict, error in
                    .responseJSON { response in
                        print("\(response)")
                        print(self.episode!.episodeTitle)
                        // MARK: TODO revisit this
//                        let httpresponse: NSHTTPURLResponse = response.statusCode
//                        let statusCode = httpresponse.statusCode
//                        if (statusCode == 200) {
//                            let url = httpresponse.URL!
//                            self.delegate?.didReceiveDownload(self.episode!)
//                            self.updateUserDefaults(episodeData, url: url)
//                        } else {
//                            print("Download Errror")
//                            AudioServicesPlaySystemSound(1053)
//                        }
                    }
            }
        }
    }
    /**
     * Function to update persistant storage with data on the podcast
     **/
    func updateUserDefaults(episodeData: [String : String], url: NSURL) throws {
        
        let fullURL = "\(url)"
        var seperate = fullURL.componentsSeparatedByString("/")
        let fileslug = seperate[seperate.count-1]
        var split = fileslug.componentsSeparatedByString("?")
        let filename: String! = split[0]
        let connected = try Reachability.isConnectedToNetwork()
        if connected {
            if let artworkString = episodeData["artwork"] {
                let artworkURL = NSURL(string: artworkString)
                let artworkData = NSData(contentsOfURL: artworkURL!)
                _ = UIImage(data: artworkData!) // artowkr image
            }
        }
        
        print("Filename after split: \(filename)")
        print("URL after split: \(fileslug)")
        print("Episode Data For \(filename): \(episodeData)")

        defaults.setObject(episodeData, forKey: filename)
        defaults.setObject(filename, forKey: fullURL)
    }
    
    // Not in use, for future version when I figure out how writing MetaData works
    func writeMetaData(filename: String) {
        // get location and path of downloaded file
        let documentsPath = "\(documentsUrl)"
        let fileString = documentsPath+"/"+filename
        let fileURL: NSURL! = NSURL(string: fileString)!
        
        // get AVAssets and MetaData that currently exist
        let item = AVPlayerItem(URL: fileURL)
        let asset: AVAsset = item.asset
        let metaItems: Int = asset.commonMetadata.count
        print(metaItems)

        // causing errors, come back
//        var metaItem: AVMetadataItem
//        var list = [AVMetadataItem]() // list
//        
//        // setup new file and newfile path
//        let newFileName = filename+"-copy"
//        var outputPath = documentsPath+"/"+newFileName // output path
//        
//        // prepare to create new metadata
//        var newArray = [AVMetadataItem]()
        
    }
    
    /**
     * Function to check the file has not been downloaded already
     * Does not work for RelayFM files & podcasts using a similar delivery method
     * where download link mp3 is not the actual filename.
    **/
    func isDuplicate(fileURL: NSURL) throws -> Bool {
        
        // strip out filename from the URL
        let urlAsString = "\(fileURL)"
        let path = urlAsString.componentsSeparatedByString("/")
        if path.count > 0 {
            let filename = path[path.count-1]
            // Find the Documents directory
            let fileManager = NSFileManager.defaultManager()
            let folderPathURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0]
                if let directoryURLs = try? fileManager.contentsOfDirectoryAtURL(folderPathURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles) {
                // for all mp3 files in the documents directory, match them against our target filename. If they match, send back true
                let mp3Files = directoryURLs.filter { $0.pathExtension == "mp3" }.map { $0.lastPathComponent! }
                for file: String in mp3Files {
                    if filename == file {
                        self.duplicate = true
                        return self.duplicate!
                    }
                }
            }
        }
        return self.duplicate!
    }
}
