//
//  NowPlayingViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class NowPlayingViewController: UIViewController {

    var episode: PodcastEpisode?
    var time: NSTimeInterval?
    var episodeTitle: String?
    var isAudioPlaying = false
    var podcastFile: NSData?
    var myPlayer = AVAudioPlayer()
    var podcastArtwork: UIImage?
    var podcastArtist: String?

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    @IBOutlet weak var amountPlayedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!{
        didSet{
            if self.isAudioPlaying {
                playButton.setTitle("Pause", forState: UIControlState.Normal)
                // grab play location and store it
            } else {
                // load play location
                playButton.setTitle("Play", forState: UIControlState.Normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PodcastPlayer.sharedInstance.prepareAudio(podcastFile!)

        playButton.setTitle("Pause", forState: UIControlState.Normal)
        if podcastArtwork != nil {
            artworkImageView.image = podcastArtwork!
        }
        episodeTitleLabel.text = episodeTitle!
        episodeDescriptionLabel.text = podcastArtist
        
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            if podcastArtwork != nil {
                let image: UIImage = podcastArtwork!
                let albumArt = MPMediaItemArtwork(image: image)
                println(albumArt)
                var podcastInfo: NSMutableDictionary = [
                    MPMediaItemPropertyAlbumTitle: episodeTitle!,
                    MPMediaItemPropertyArtist: podcastArtist!,
                    MPMediaItemPropertyArtwork: albumArt
                ]
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = podcastInfo as [NSObject: AnyObject]
            } else {
                var podcastInfo: NSMutableDictionary = [
                    MPMediaItemPropertyAlbumTitle: episodeTitle!,
                    MPMediaItemPropertyArtist: podcastArtist!
                ]
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = podcastInfo as [NSObject: AnyObject]
            }
        } else {
            println("error here")
        }
        if (AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)) {
            println("Receiving remote control")
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } else {
            println("Audio session error")
        }
    }

    func prepareAudio(myData: NSData) {
        myPlayer = AVAudioPlayer(data: myData, error: nil)
        myPlayer.prepareToPlay()
    }
    
    func toggle() {
        if isAudioPlaying {
            PodcastPlayer.sharedInstance.pause()
            playButton.setTitle("Play", forState: UIControlState.Normal)
            time = PodcastPlayer.sharedInstance.currentTime
        } else {
            PodcastPlayer.sharedInstance
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func PlayAudio(sender: UIButton) {
        toggle()
    }
    
    @IBAction func SkipForward(sender: UIButton) {
        
    }
    
    @IBAction func SkipBack(sender: UIButton) {
        
    }
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
    
    }
    
    @IBAction func shareButtonClicked(sender: UIButton)
    {
        let textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = NSURL(string: "http://www.codingexplorer.com/")
        {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

}

