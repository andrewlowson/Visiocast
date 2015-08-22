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
    
    let api = DownloadManager() // Needs to be delegate so we can get information about new shows when they're downloaded
    let defaults = NSUserDefaults.standardUserDefaults() // Storage area for Podcast Information

    // Main UI elements in View
    @IBOutlet weak var episodesTableView: UITableView!
    @IBOutlet weak var downloadsTableView: UITableView!
    @IBOutlet weak var DownloadsTabBarItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // layout the TableView rows
        episodesTableView.estimatedRowHeight = episodesTableView.rowHeight
        episodesTableView.rowHeight = UITableViewAutomaticDimension

        // set up delegates to all things that receive data
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        api.delegate = self
        
     //   loadFiles() //method to layout the files
        episodesTableView.reloadData()
    }

    // Method to make sure data changed between view changes are known to the UI
    override func viewDidAppear(animated: Bool) {
        podcasts.removeAll()
        loadFiles()
    }
        
    // This searches the documents directory and grabs all the files in it.
    func loadFiles() {
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {

            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
            
            // for each MP3 file in the Documents directory we want all the data on it and to create objecst for the podcasts
            for (file: String) in mp3Files {
                
                var backup = defaults.objectForKey(file) as? [String : String]
                
                var fileString = "\(documentsUrl)"+file
                var fileURL: NSURL! = NSURL(string: fileString)!
                
                let item = AVPlayerItem(URL: fileURL)
                let metadataList = item.asset.commonMetadata as! [AVMetadataItem]
                
                let metaDataItem = item.asset.metadata as! [AVMetadataItem]

                
                var title: String?
                var artist: String?
                var podcastTitle: String?
                var artwork: UIImage?
                var artworkString: String?
                
                
                // This block deals with MetaData in the MP3 File
                for item in metadataList {
                    if item.commonKey == nil {
                        continue
                    }
                    if let key = item.commonKey, let value = item.value {
                        if key == "title" {
                            title = value as? String
                            println(title!)
                        }
                        if key == "artist" {
                            artist = value as? String
                        }
                        if key == "albumName" {
                            podcastTitle = value as? String
                        }
                        if key == "artwork" {
                            if let image = UIImage(data: value as! NSData) {
                                artwork = image
                            }
                        }
                    }
                }
                
                //This block from line 106 - 149 exists for cases where metadata is missing (often)
                if let backup = defaults.objectForKey(file) as? [String : String] {
                    title = backup["title"]
                    println(title!)
                    artworkString = backup["artwork"]
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        if let artworkURLAsString = backup["artwork"] {
                            var  artworkURL = NSURL(string: artworkURLAsString)
                            if Reachability.isConnectedToNetwork() {
                                var artworkData = NSData(contentsOfURL: artworkURL!)
                                if artwork == nil {
                                    artwork = UIImage(data: artworkData!)
                                }
                                self.podcastArtwork[artworkURL!] = artwork
                            }
                        }
                    }
                }
                if (artist == nil) {
                    artist = file
                }
                if (podcastTitle == nil) {
                    if let backup = defaults.objectForKey(file) as? [String : String] {
                        if let podcastName = backup["podcast"] {
                            podcastTitle = podcastName
                        } else {
                            podcastTitle = backup["title"]!
                        }
                    }
                }
                if artworkString == nil {
                    artworkString = ""
                }
                var publishedDate: NSDate?
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
                
                publishedDate = dateFormatter.dateFromString("Wed, 29 Jul 2015 13:52:35 +0000")
                
                var podcast = Podcast(title: podcastTitle!, artist: artist!, artwork: artworkString!, feedURL: "")
                var episode = PodcastEpisode(title: title!, description: file as String, date: publishedDate!, duration: "", download: "", subtitle: "", size: 0, podcast: podcast)
                podcasts.append(episode)
            }
            episodesTableView.reloadData()
        }
        episodesTableView.reloadData()
    }
    
    // if an episode is downloaded during the lifecycle of the application and I'm in this view, load the episode
    func didReceiveDownload(episode: PodcastEpisode) {        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.podcasts.append(episode)
            self.loadFiles()
            self.episodesTableView.reloadData()
        }
    }
    
    // MARK: - Navigation
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
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let artwork = UIImage(data: data)
                    // Store the image in to our cache
                    self.podcastArtwork[cell.episode!.podcast!.podcastArtwork!] = artwork
                    // Update the cell
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.episodeArtworkImageView?.image = artwork
                    })
                }
                else {
                    println("Error 1: \(cell.episode!.episodeTitle!)")
                    println("Error 2: \(cell.episode!.podcast!.podcastFeed!)")
                    println("Error 3: \(error.localizedDescription)")
                }
            })
        }
        
        return cell
    }

    // NowPlaying Segue. Set up the Player and podcast details for NowPlayingViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Get the new view controller using segue.destinationViewController.
        //Pass the selected object to the new view controller.
        let nav = segue.destinationViewController as! UINavigationController
        let nowPlaying = nav.topViewController as! NowPlayingViewController
        
        var fileIndex = episodesTableView!.indexPathForSelectedRow()!.row
        
        var thisFileName = podcasts[fileIndex].episodeDescription!
        
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        let documentsPath = documentsUrl.absoluteString
    
        var fileString = documentsPath!+thisFileName
        let fileURL = NSURL(string: fileString)
        var file = NSData(contentsOfURL: fileURL!)

        var title = podcasts[fileIndex].episodeTitle!
        var podcast = podcasts[fileIndex].podcast
        if PodcastPlayer.sharedInstance.currentlyPlaying() {
            PodcastPlayer.sharedInstance.pause()
        }
        nowPlaying.title = title
        nowPlaying.filename = fileString
        nowPlaying.podcastFile = (file)
        nowPlaying.episode = podcasts[fileIndex]
        nowPlaying.episodeTitleLabel?.text = title
    
        if podcastArtwork[podcast!.podcastArtwork] != nil {
            nowPlaying.podcastArtwork = podcastArtwork[podcast!.podcastArtwork]!
        }

        nowPlaying.artworkImageView?.image = podcastArtwork[podcast!.podcastArtwork]!
        nowPlaying.podcastArtist = podcasts[fileIndex].podcast?.podcastArtistName
    }
    
    
    // Allow the ability to slide to delete a row.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //On Slide to delete, make sure that the file is removed from Downloads Folder
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // Find the file
            var error:NSError?
            var manager = NSFileManager.defaultManager()
            var path = manager.documentsDirectoryPath()
            var filename = podcasts[indexPath.row].episodeDescription!
            var filepath = path+"/"+filename

            // remove the file from the array, the row, the array
            manager.removeItemAtPath(filepath, error: &error)
            podcasts.removeAtIndex(indexPath.row)
            if error != nil {
                println(filepath)
                println(error?.localizedDescription)
            }
            
            //redraw the table with the file deleted
            podcasts.removeAll()
            loadFiles()
        }
    }
}

extension NSFileManager {
    func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        
        return documentsDirectory as! String
    }
}