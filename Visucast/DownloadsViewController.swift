//
//  DownloadsViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import AVFoundation

class DownloadsViewController: UIViewController, UITableViewDelegate, AVAudioPlayerDelegate, UITableViewDataSource , DownloadManagerProtocol {

    var podcasts = [PodcastEpisode]()
    
    var podcastArtwork = [NSURL: UIImage]()
    
    @IBOutlet weak var episodesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let api = DownloadManager()
        
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        
        episodesTableView.estimatedRowHeight = episodesTableView.rowHeight
        episodesTableView.rowHeight = UITableViewAutomaticDimension
        
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            //println(directoryUrls)
            
            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }

            for (file: String) in mp3Files {
                println(file)
                var fileString = "\(documentsUrl)"+file
                
                var fileURL: NSURL! = NSURL(string: fileString)!
                
                let item = AVPlayerItem(URL: fileURL)
                let metadataList = item.asset.commonMetadata as! [AVMetadataItem]
                
                var title: String?
                var artist: String?
                var podcastTitle: String?
                for item in metadataList {
                    if (item.commonKey != nil && item.stringValue != nil) {
                        println("\(item.commonKey) = " + item.stringValue)
                        if (item.commonKey == "title") {
                            title = item.stringValue
                        }
                        if (item.commonKey == "artist") {
                            artist = item.stringValue
                        }
                        if (item.commonKey == "albumName"){
                            podcastTitle = item.stringValue
                        }
                    }
                }
                
                if (title == nil) {
                    title = file
                }
                if (artist == nil) {
                    artist = file
                }
                if (podcastTitle == nil) {
                    podcastTitle = file
                }
                //println(fileURL)
                println(file)
                println()
                var publishedDate: NSDate?
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
                
                publishedDate = dateFormatter.dateFromString("Wed, 29 Jul 2015 13:52:35 +0000")
                
                var podcast = Podcast(title: podcastTitle!, artist: artist!, artwork: "", feedURL: "")
                var episode = PodcastEpisode(title: title!, description: file, date: publishedDate!, duration: "", download: "", subtitle: "", size: 0, podcast: podcast)
                
                podcasts.append(episode)
            }
            episodesTableView.reloadData()
           // println("MP3 FILES:\n" + mp3Files.description)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        podcasts.removeAll()
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            //println(directoryUrls)
            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
            
            for (file: String) in mp3Files {
                println(file)
                var fileString = "\(documentsUrl)"+file
                
                var fileURL: NSURL! = NSURL(string: fileString)!
                
                let item = AVPlayerItem(URL: fileURL)
                let metadataList = item.asset.commonMetadata as! [AVMetadataItem]
                
                var title: String?
                var artist: String?
                var podcastTitle: String?
                for item in metadataList {
                    if (item.commonKey != nil && item.stringValue != nil) {
                        println("\(item.commonKey) = " + item.stringValue)
                        if (item.commonKey == "title") {
                            title = item.stringValue
                        }
                        if (item.commonKey == "artist") {
                            artist = item.stringValue
                        }
                        if (item.commonKey == "albumName"){
                            podcastTitle = item.stringValue
                        }
                    }
                }
                
                if (title == nil) {
                    title = file
                }
                if (artist == nil) {
                    artist = file
                }
                if (podcastTitle == nil) {
                    podcastTitle = file
                }
                //println(fileURL)
                println(file)
                println()
                var publishedDate: NSDate?
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
                
                publishedDate = dateFormatter.dateFromString("Wed, 29 Jul 2015 13:52:35 +0000")
                
                var podcast = Podcast(title: podcastTitle!, artist: artist!, artwork: "", feedURL: "")
                var episode = PodcastEpisode(title: title!, description: file, date: publishedDate!, duration: "", download: "", subtitle: "", size: 0, podcast: podcast)
                
                podcasts.append(episode)
            }
            episodesTableView.reloadData()
        }
    }
    
    
    func didReceiveDownload(episode: PodcastEpisode) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.podcasts.append(episode)
            self.episodesTableView.reloadData()
        }
    }
    
    @IBOutlet weak var downloadsTableView: UITableView!

    @IBOutlet weak var DownloadsTabBarItem: UITabBarItem!
    
    func addPodcast(podcast: PodcastEpisode, downloadURL: NSURL) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Episode"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! DownloadsTableViewCell
        
        cell.episode = podcasts[indexPath.row]
        
        if let artwork = podcastArtwork[cell.episode!.podcast!.podcastArtwork!] {
            cell.episodeArtworkImageView?.image = artwork
        }
        else {
            // The image isn't cached, download the image data
            // We should perform this in a background thread
            let request: NSURLRequest = NSURLRequest(URL: cell.episode!.podcast!.podcastArtwork!)
            println(cell.episode!.podcast!.podcastArtwork!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let artwork = UIImage(data: data)
                    // Store the image in to our cache
                    self.podcastArtwork[self.podcasts[indexPath.row].podcast!.podcastArtwork!] = artwork
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.episodeArtworkImageView?.image = artwork
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }

        
        
        return cell
    }
    

    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//         //Get the new view controller using segue.destinationViewController.
//         //Pass the selected object to the new view controller.
//        var nowPlaying: NowPlayingViewController = segue.destinationViewController as! NowPlayingViewController
//        var fileIndex = episodesTableView!.indexPathForSelectedRow()!.row
//        
//        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
//        
//        var fullPath = "\(documentsUrl)" + podcasts[fileIndex].filePath!
//        println(fullPath)
//        nowPlaying.episode = podcasts[fileIndex]
//        //nowPlaying.episodeTitle = podcasts[fileIndex]
//    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var fileIndex = episodesTableView!.indexPathForSelectedRow()!.row
        
        var thisFileURL = podcasts[fileIndex].description as String
        print("url:" + thisFileURL)
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil)

        var fullPath = "\(documentsUrl)" + podcasts[fileIndex].description
        
        var player : AVAudioPlayer! = nil // will be Optional, must supply initializer
        
        var fileString = "\(documentsUrl)"+"news-321.mp3"
        var fileTitle = podcasts[fileIndex].description as String
        let path = fileString
        let fileURL = NSURL(fileURLWithPath: path)
        player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        player.prepareToPlay()
        player.delegate = self
     
        player.play()
    }
}

extension NSFileManager {
    func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        
        return documentsDirectory as! String
    }
}