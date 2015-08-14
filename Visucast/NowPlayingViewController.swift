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
        isAudioPlaying = true
        if podcastArtwork != nil {
            artworkImageView.image = podcastArtwork!
        }
        if episodeTitle != nil {
            episodeTitleLabel.text = episodeTitle!
        } else {
            episodeTitleLabel.text = podcastArtist
        }
        
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
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
        
        let sharingContents = "Listen to \(episodeTitle!). via Visiocast"
        
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [sharingContents], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func PlayAudio(sender: UIButton) {
        PodcastPlayer.sharedInstance.toggle()
        if (PodcastPlayer.sharedInstance.currentlyPlaying()) {
            sender.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            sender.setTitle("Play", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func SkipForward(sender: UIButton) {
        PodcastPlayer.sharedInstance.skipForward()
    }
    
    @IBAction func SkipBack(sender: UIButton) {
        PodcastPlayer.sharedInstance.skipBack()
    }
    
    
    
}

