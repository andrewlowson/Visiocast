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
        do {
            try loadFiles()
        } catch {
            print("Loading files didn't work")
        }
    }
        
    // This searches the documents directory and grabs all the files in it.
    func loadFiles() throws {
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] 
        
        // if you want to filter the directory contents you can do like this:
//        if let directoryUrls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants)  {
        let fileManager = NSFileManager.defaultManager()
        let folderPathURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0]
        if let directoryURLs = try? fileManager.contentsOfDirectoryAtURL(folderPathURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles) {
            
            let mp3Files = directoryURLs.filter { $0.pathExtension == "mp3" }.map { $0.lastPathComponent! }
            
            // for each MP3 file in the Documents directory we want all the data on it and to create objecst for the podcasts
            for file: String in mp3Files {
                
                _ = defaults.objectForKey(file) as? [String : String]
                
                let fileString = "\(documentsUrl)"+file
                let fileURL: NSURL? = NSURL(string: fileString)
                var title: String?
                var artist: String?
                var podcastTitle: String?
                var artwork: UIImage?
                var artworkString: String?
                
                let item = AVPlayerItem(URL: fileURL!)
                let metadataList = item.asset.commonMetadata 
                _ = item.asset.metadata
                    
                    // This block deals with MetaData in the MP3 File
                    for item in metadataList {
                        if item.commonKey == nil {
                            continue
                        }
                        if let key = item.commonKey, let value = item.value {
                            if key == "title" {
                                title = value as? String
                                print(title!)
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

                
                //This block from line 106 - 149 exists for cases where metadata is missing (this happens a lot)
                if let backup = defaults.objectForKey(file) as? [String : String] {
                    title = backup["title"]
                    print(title!)
                    artworkString = backup["artwork"]
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        do {
                            if let artworkURLAsString = backup["artwork"] {
                            var  artworkURL = NSURL(string: artworkURLAsString)
                                var connected = try Reachability.isConnectedToNetwork()
                                if connected {
                                    var artworkData = NSData(contentsOfURL: artworkURL!)
                                    if artwork == nil {
                                        artwork = UIImage(data: artworkData!)
                                    }
                                    self.podcastArtwork[artworkURL!] = artwork
                                }
                            }
                        } catch {print("thing")}
                    }
                }
                if artist == nil {
                    artist = file
                }
                if title == nil {
                    title = file
                }
                if podcastTitle == nil {
                    if let backup = defaults.objectForKey(file) as? [String : String] {
                        if let podcastName = backup["podcast"] {
                            podcastTitle = podcastName
                        } else {
                            podcastTitle = backup["title"]!
                        }
                    } else {
                        podcastTitle = file
                        print("the persistent storage wasn't written for \(file)")
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
        dispatch_async(dispatch_get_main_queue()) { ()  -> Void in
            self.podcasts.append(episode)
            do {try self.loadFiles()} catch{}
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
            //let mainQueue = NSOperationQueue.mainQueue()
            
            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            //NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let artwork = UIImage(data: data!)
                    // Store the image in to our cache
                    self.podcastArtwork[cell.episode!.podcast!.podcastArtwork!] = artwork
                    // Update the cell
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.episodeArtworkImageView?.image = artwork
                    })
                }
                else {
                    print("Error 1: \(cell.episode!.episodeTitle!)")
                    print("Error 2: \(cell.episode!.podcast!.podcastFeed!)")
                    print("Error 3: \(error!.localizedDescription)")
                }
            }
        }
        
        return cell
    }

    // NowPlaying Segue. Set up the Player and podcast details for NowPlayingViewController
    // This requires sending all the data from the persistent storage to the PodcastPlayer class and the NowPlayingClass 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Get the new view controller using segue.destinationViewController.
        //Pass the selected object to the new view controller.
        let nav = segue.destinationViewController as! UINavigationController
        let nowPlaying = nav.topViewController as! NowPlayingViewController
        

        let fileIndex = episodesTableView!.indexPathForSelectedRow!.row  // podcast episode row selected by the user
        let thisFileName = podcasts[fileIndex].episodeDescription!         // it's filename
        
        // previous var paths:[AnyObject] No idea wthat the _ is for....
        _ = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let documentsPath = documentsUrl.absoluteString
    
        let fileString = documentsPath+thisFileName
        let fileURL = NSURL(string: fileString)
        
        
        if fileURL == nil { // if the filestring cannot be read
            
            let alertController = UIAlertController(title: "Playback Error", message: "I'm having an issue with this file.\nPlease delete it.", preferredStyle: .Alert)
            alertController.isAccessibilityElement = true
            // Set up default OK action for user to dismiss alert
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)
        } else {
            let file = NSData(contentsOfURL: fileURL!)
            let title = podcasts[fileIndex].episodeTitle!
            let podcast = podcasts[fileIndex].podcast
            
            // this could perform better, should add a 'if playing this file, skip reloading file in ViewDidLoad()'
            if PodcastPlayer.sharedInstance.currentlyPlaying() {
                PodcastPlayer.sharedInstance.pause()
            }
            // data for the elements in NowPplaying
            nowPlaying.title = title
            nowPlaying.podcast = podcast!.podcastTitle
            nowPlaying.episodeTitle = title
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
    }
    
    
    // Allow the ability to slide to delete a row.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //On Slide to delete, make sure that the file is removed from Downloads Folder
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // Find the file
            let error:NSError?
            let manager = NSFileManager.defaultManager()
            let path = manager.documentsDirectoryPath()
            let filename = podcasts[indexPath.row].episodeDescription!
            let filepath = path+"/"+filename

            // remove the file from the array, the row, the array
            do {
                try manager.removeItemAtPath(filepath)
                podcasts.removeAtIndex(indexPath.row)
//                if error != nil {
//                    print(filepath)
//                    print(error?.localizedDescription)
//                } else {
//                    AudioServicesPlaySystemSound(1054)
//                }
                
                //redraw the table with the file deleted
                podcasts.removeAll()
            
                try loadFiles()
            } catch {
                print("Loading files didn't work: 307")
            }
        }
    }
}

 // extension to return the documents container absolute path as a String
extension NSFileManager {
    func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        
        return documentsDirectory as! String
    }
}