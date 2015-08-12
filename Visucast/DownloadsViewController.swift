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
    
    var podcastArtwork = [String: UIImage]()
    
    var myPlayer = AVAudioPlayer()
    let api = DownloadManager()

    
    @IBOutlet weak var episodesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        episodesTableView.estimatedRowHeight = episodesTableView.rowHeight
        episodesTableView.rowHeight = UITableViewAutomaticDimension

        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        api.delegate = self
        
        loadFiles()
        episodesTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        podcasts.removeAll()
        loadFiles()
    }
    
    func loadFiles() {
        
        if api.duplicate == true {
            var alert = UIAlertController(title: "Duplicate", message: "You've Already Downloaded This", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    println("default")
                    
                case .Cancel:
                    println("cancel")
                    
                case .Destructive:
                    println("destructive")
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {

            let mp3Files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "mp3" }
            
            for (file: String) in mp3Files {

                var fileString = "\(documentsUrl)"+file
                
                var fileURL: NSURL! = NSURL(string: fileString)!
                
                let item = AVPlayerItem(URL: fileURL)
                let metadataList = item.asset.commonMetadata as! [AVMetadataItem]
                
                var title: String?
                var artist: String?
                var podcastTitle: String?
                var artwork: UIImage?
                for item in metadataList {
                    
                    if item.commonKey == nil {
                        continue
                    }
                    if let key = item.commonKey, let value = item.value {
                        if key != "artwork" {
                            println("\(key)  \(value)")
                        }
                        if key == "title" {
                            title = value as? String
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
                println()
                if artwork == nil {
                  // fix it.
                } else {
                    self.podcastArtwork[title!] = artwork!
                }

                var publishedDate: NSDate?
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
                
                publishedDate = dateFormatter.dateFromString("Wed, 29 Jul 2015 13:52:35 +0000")
                
                var podcast = Podcast(title: podcastTitle!, artist: artist!, artwork: "", feedURL: "")
                var episode = PodcastEpisode(title: title!, description: file as String, date: publishedDate!, duration: "", download: "", subtitle: "", size: 0, podcast: podcast)
                podcasts.append(episode)
            }
            episodesTableView.reloadData()
        }

        episodesTableView.reloadData()
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
        var podcast = podcasts[indexPath.row]
        var title = podcast.episodeTitle!
        var description = podcast.episodeDescription!
        var artwork = podcastArtwork[title]
        
        if let artwork = podcastArtwork[podcast.episodeTitle!] {
            cell.episodeArtworkImageView?.image = artwork
        }

        return cell
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         //Get the new view controller using segue.destinationViewController.
         //Pass the selected object to the new view controller.
        let nav = segue.destinationViewController as! UINavigationController
        let nowPlaying = nav.topViewController as! NowPlayingViewController
        var fileIndex = episodesTableView!.indexPathForSelectedRow()!.row
        
        var title = podcasts[fileIndex].episodeTitle!
        println(title)
        println(podcastArtwork)
        //        nowPlaying.artworkImageView.image = podcastArtwork[podcasts[fileIndex].episodeTitle!]
        
        nowPlaying.episode = podcasts[fileIndex]
        nowPlaying.episodeTitle = title
        nowPlaying.artworkImageView?.image = podcastArtwork[title]
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var thisFileName = podcasts[indexPath.row].episodeDescription!
        
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        let documentsPath = documentsUrl.absoluteString
        
        var fileString = documentsPath!+thisFileName
        let fileURL = NSURL(string: fileString)
        var file = NSData(contentsOfURL: fileURL!)
        println(fileURL!)
        println()
        println(file!.length)
        self.prepareAudio(file!)

        self.myPlayer.play()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // grab the file path,
            var error:NSError?
            var manager = NSFileManager.defaultManager()
            var path = manager.documentsDirectoryPath()
            var filename = podcasts[indexPath.row].episodeDescription!
            var filepath = path+"/"+filename
            manager.removeItemAtPath(filepath, error: &error)
            podcasts.removeAtIndex(indexPath.row)
            if error != nil {
                println(filepath)
                println(error?.localizedDescription)
            }
            
            loadFiles()
        }
    }
    
    func prepareAudio(myData: NSData) {
        myPlayer = AVAudioPlayer(data: myData, error: nil)
        myPlayer.prepareToPlay()
    }
}

extension NSFileManager {
    func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        
        return documentsDirectory as! String
    }
}