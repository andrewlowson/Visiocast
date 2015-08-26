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
    var filename: String?
    var myPlayer = AVAudioPlayer()
    var podcastArtwork: UIImage?
    var podcastArtist: String?
    var podcast: String?

    @IBOutlet weak var trackSlider: UISlider!
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
        
        PodcastPlayer.sharedInstance.prepareAudio(podcastFile!, filename: filename!)
        
        playButton.setTitle("Pause", forState: UIControlState.Normal)
        isAudioPlaying = true
        if podcastArtwork != nil {
            artworkImageView.image = podcastArtwork!
        }
        trackSlider.maximumValue = Float(PodcastPlayer.sharedInstance.duration())

        
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            if podcastArtwork != nil {
                let image: UIImage = podcastArtwork!
                let albumArt = MPMediaItemArtwork(image: image)
                println(albumArt)
                var podcastInfo: NSMutableDictionary = [
                    MPMediaItemPropertyTitle: episodeTitle!,
                    MPMediaItemPropertyArtist: podcast!,
                    MPMediaItemPropertyArtwork: albumArt
                ]
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = podcastInfo as [NSObject: AnyObject]
            } else {
                var podcastInfo: NSMutableDictionary = [
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
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("updateAudioTime"), userInfo: nil, repeats: true )

       
        
        setupSlider()
    }

    @IBAction func shareButton(sender: UIBarButtonItem) {
        
        let sharingContents = "Listen to \(episodeTitle!). via Visiocast"
        
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [sharingContents], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func changeTrackTime(sender: AnyObject) {
        PodcastPlayer.sharedInstance.stop()
        PodcastPlayer.sharedInstance.setTime(NSTimeInterval(trackSlider.value))
        setupSlider()
        PodcastPlayer.sharedInstance.play()
    }
    
    // Set up the accessibility elements and values for the slider
    func setupSlider() {
        trackSlider.isAccessibilityElement = true
        
        var duration: NSTimeInterval = PodcastPlayer.sharedInstance.duration()
        let ti = NSInteger(duration)
        let ms = Int((duration % 1) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        
        var durationString: NSString
        
        if hours < 1 {
            durationString = NSString(format: "%0.2d minutes and %0.2d seconds.", minutes,seconds)
        } else {
            durationString = NSString(format: "%0.2d hours, %0.2d minutes and %0.2d seconds.",hours,minutes,seconds)
        }
        
        
        var played: NSTimeInterval = PodcastPlayer.sharedInstance.getTime()
        println(played)
        let nextInterval = Int(played)
        let secondsPlayed = nextInterval % 60
        let minutesPlayed = (nextInterval / 60) % 60
        let hoursPlayed = (nextInterval / 3600)
        
        var playedString: NSString
        
        if hoursPlayed < 1 {
            playedString = NSString(format: "%0.2d minutes and %0.2d seconds played", minutesPlayed,secondsPlayed)
        } else {
            playedString = NSString(format: "%0.2d hours, %0.2d minutes and %0.2d seconds played",hoursPlayed ,minutesPlayed,secondsPlayed)
        }
        
        println (playedString)
        trackSlider.accessibilityValue = "\(playedString) of \(durationString)"

    }
    
    // Update audio times
    func updateAudioTime() {
        
        var time = PodcastPlayer.sharedInstance.getTime()
        var timeRemaining = PodcastPlayer.sharedInstance.duration() - time
        trackSlider.value = Float(time)
        
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        var result =  String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        amountPlayedLabel.text = "\(result)"
        var amountPlayedValue: NSString = String(format: "%02d hours, %02 minutes and  %02 seconds", hours, minutes, seconds)
        amountPlayedLabel.accessibilityValue = amountPlayedValue as String

        let nextInterval = Int(timeRemaining)
        let secondsLeft = nextInterval % 60
        let minutesLeft = (nextInterval / 60) % 60
        let hoursLeft = (nextInterval / 3600)
        
        var formattedTime =  String(format: "%02d:%02d:%02d", hoursLeft, minutesLeft, secondsLeft)
        timeRemainingLabel.text = "\(formattedTime)"
        var remainingValue: NSString = String(format: "%02d hours, %02d minutes and %02d seconds", hoursLeft, minutesLeft, secondsLeft)
        timeRemainingLabel.accessibilityValue = remainingValue as String
        
        setupSlider()
        if PodcastPlayer.sharedInstance.currentlyPlaying() {
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
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
