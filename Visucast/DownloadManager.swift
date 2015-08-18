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
import UIKit

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
     * Main function to download an episode of a podcast.
     * Prints out the progress state as a percentage and as a total
     * 
     **/
    func initiateDownload(podcastEpisode: PodcastEpisode, downloadURL: NSURL, episodeData: [String: String]) {
        episode = podcastEpisode
        if Reachability.isConnectedToNetwork() {
            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
            
            // start the download off the main thread so UI still remains responsive
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                Alamofire.download(.GET, downloadURL, destination: destination)
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        
                        var inBytes = totalBytesExpectedToRead
                        var inMBytes = Double( (totalBytesExpectedToRead / 1024) / 1024)
                        var soFar = Double(totalBytesRead / 1024) / 1024
                        var percentage = (soFar / inMBytes) * 100
                        var someDoubleFormat = ".3"
                        
                        println("\(percentage.format(someDoubleFormat))% Complete. \(soFar.format(someDoubleFormat))MB of \(inMBytes)MB downloaded.")
                    }
                    .responseJSON { request, response, jsonDict, error in
                        println("\(response!)")
                        println(self.episode!.episodeTitle)
                        let httpresponse: NSHTTPURLResponse = response!
                        let statusCode = httpresponse.statusCode
                        if (statusCode == 200) {
                            let url = httpresponse.URL!
                            self.delegate?.didReceiveDownload(self.episode!)
                            self.updateUserDefaults(episodeData, url: url)
                        } else {
                            println("Download Errror")
                        }
                    }
            }
        }
    }
    
    func updateUserDefaults(episodeData: [String : String], url: NSURL) {
        
        var fullURL = "\(url)"
        var seperate = fullURL.componentsSeparatedByString("/")
        var fileslug = seperate[seperate.count-1]
        var split = fileslug.componentsSeparatedByString("?")
        var filename: String! = split[0]
        
        var artworkURL = NSURL(string: episodeData["artwork"]!)
        var artworkData = NSData(contentsOfURL: artworkURL!)
        var artwork = UIImage(data: artworkData!)
        
        println("Filename after split: \(filename)")
        println("URL after split: \(fileslug)")
        println("Episode Data For Download: \(episodeData)")
        
        defaults.setObject(episodeData, forKey: filename)
        defaults.setObject(filename, forKey: fullURL)
    }
    
    // Not in use, for future version when I figure out how writing MetaData works
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
    
    /**
     * Function to check the file has not been downloaded already
     * Does not work for RelayFM files & podcasts using a similar delivery method
     * where download link mp3 is not the actual filename.
    **/
    func isDuplicate(fileURL: NSURL) -> Bool {
        
        // strip out filename from the URL
        let urlAsString = "\(fileURL)"
        let path = split(urlAsString) {$0 == "/"}
        let filename = path[path.count-1]
        
        // Find the Documents directory
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            
            // for all mp3 files inthe documents directory, match them against our target filename. If they match, send back true
            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
            for file: String in mp3Files {
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
