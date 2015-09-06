//
//  NowPlayingViewController.swift
//  Visucast
//
//  This is a class to manage all the UI elements and values on the NowPlaying view
//  It is closely linked to the static PodcastPlayer as it requires frequent updates on the status of that class.
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//
//  

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class NowPlayingViewController: UIViewController {

    var episode: PodcastEpisode? // PodcastEpisode that is currently being played
    var time: NSTimeInterval? // the current elapsed time of the Player (possibly not in use anymore, should only use getTime() in Player class)
    var episodeTitle: String? // title for title bar and label
    var isAudioPlaying = false // used to set play button to play or pause, should use teh Player boolean instead of this.
    var podcastFile: NSData? // raw mp3 data
    var filename: String? // used to retrieve data in storage
    var myPlayer = AVAudioPlayer() // mp3 player object, should use PodcastPlayer instance instead
    var podcastArtwork: UIImage? // artowrk image
    var podcastArtist: String? // not in use
    var podcast: String? // podcsat title
    let defaults = NSUserDefaults.standardUserDefaults() // access to persistent storage

    @IBOutlet weak var trackSlider: UISlider! // time elapsed slider.
    @IBOutlet weak var shareButton: UIButton! // System Action Share sheet
    @IBOutlet weak var episodeTitleLabel: UILabel! // // set as white text so it not visible but is still selectable
    @IBOutlet weak var episodeDescriptionLabel: UILabel! // not in use
    @IBOutlet weak var amountPlayedLabel: UILabel! // labl under time slider displaying time elapsed
    @IBOutlet weak var timeRemainingLabel: UILabel! // label under time slider displaying time remainging
    @IBOutlet weak var artworkImageView: UIImageView! // container for artwork image
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
        
        // prepare to start playing the file selected by the user that brought them to this view
        // set all the element values
        PodcastPlayer.sharedInstance.prepareAudio(podcastFile!, filename: filename!)
        if (episodeTitle != nil) {
            episodeTitleLabel.text = episodeTitle!
        }
        playButton.setTitle("Pause", forState: UIControlState.Normal)
        isAudioPlaying = true
        if podcastArtwork != nil {
            artworkImageView.image = podcastArtwork!
        }
        artworkImageView.isAccessibilityElement = false
        trackSlider.maximumValue = Float(PodcastPlayer.sharedInstance.duration())
        
        // finished setting up elements on screen

        // This is the setup area for the Lock Screen and Control Centre information
        // Pass all the information about the podcast that is required to the MPMediaItemProperty
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            if podcastArtwork != nil {
                let image: UIImage = podcastArtwork!
                let albumArt = MPMediaItemArtwork(image: image)
                println(albumArt)
                // this is all the information required for the lock screen and control centre data
                // current time needs to be added so it live updates.
                var podcastInfo: NSMutableDictionary = [
                    MPMediaItemPropertyTitle: episodeTitle!,
                    MPMediaItemPropertyArtist: podcast!,
                    MPMediaItemPropertyArtwork: albumArt,
                    MPMediaItemPropertyPlaybackDuration: PodcastPlayer.sharedInstance.duration()
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
        
        // this allows the application to receive controls from earphone or system playback controls
        if (AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)) {
            println("Receiving remote control")
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } else {
            println("Audio session error")
        }
        
        // set a timer to poll the updateAudioTime method so the slider updates live
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("updateAudioTime"), userInfo: nil, repeats: true )
        
        setupSlider()
    }

    // Function to manage the share sheet.
    @IBAction func shareButton(sender: UIBarButtonItem) {
        let sharingContents = "Listen to \(episodeTitle!). via Visiocast" // content that is shared
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [sharingContents], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // this function allows the slider to be dragged to adjust the time
    @IBAction func changeTrackTime(sender: AnyObject) {
        PodcastPlayer.sharedInstance.stop() // stop the player so we can adjust the time
        PodcastPlayer.sharedInstance.setTime(NSTimeInterval(trackSlider.value))
        setupSlider() // reset the slider
        PodcastPlayer.sharedInstance.play() // start the buffer to play the track again
    }
    
    // Set up the accessibility elements and values for the slider
    //MARK: TODO Write a function to format the time in a "x hours, y minutes and z seconds" format given an integer
    // This is done manually far too many times
    func setupSlider() {
        trackSlider.isAccessibilityElement = true
        
        // set the value for the duration of the player in Time units as opposed so an Integer
        var duration: NSTimeInterval = PodcastPlayer.sharedInstance.duration()
        let ti = NSInteger(duration)
        let ms = Int((duration % 1) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        
        var durationString: NSString
        // format the string to be read out in understandable language
        if hours < 1 { // if no hours have been elapsed, no need to say zero hours
            durationString = NSString(format: "%0.2d minutes and %0.2d seconds.", minutes,seconds)
        } else {
            durationString = NSString(format: "%0.2d hours, %0.2d minutes and %0.2d seconds.",hours,minutes,seconds)
        }
        
        // set the value for the time elapsed of the player in Time units as opposed so an Integer
        var played: NSTimeInterval = PodcastPlayer.sharedInstance.getTime()
        let nextInterval = Int(played)
        let secondsPlayed = nextInterval % 60
        let minutesPlayed = (nextInterval / 60) % 60
        let hoursPlayed = (nextInterval / 3600)
        
        var playedString: NSString
        
        if hoursPlayed < 1 { // if no hours have been elapsed, no need to say zero hours
            playedString = NSString(format: "%0.2d minutes and %0.2d seconds played", minutesPlayed,secondsPlayed)
        } else {
            playedString = NSString(format: "%0.2d hours, %0.2d minutes and %0.2d seconds played",hoursPlayed ,minutesPlayed,secondsPlayed)
        }
       
        // set slider value to be "x played of y total"
        trackSlider.accessibilityValue = "\(playedString) of \(durationString)"

    }
    
    // Update audio times
    //TODO Write a function to format the time in a "x hours, y minutes and z seconds" format given an integer
    func updateAudioTime() {
        
        // set the value for the Slider
        var time = PodcastPlayer.sharedInstance.getTime()
        var timeRemaining = PodcastPlayer.sharedInstance.duration() - time
        trackSlider.value = Float(time)
        
        // repeating of code, this needs to be refactored
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        var result =  String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        amountPlayedLabel.text = "\(result)"
        var amountPlayedValue: NSString = String(format: "%02d hours, %02d minutes and  %02d seconds", hours, minutes, seconds)
        amountPlayedLabel.accessibilityValue = amountPlayedValue as String

        let nextInterval = Int(timeRemaining)
        let secondsLeft = nextInterval % 60
        let minutesLeft = (nextInterval / 60) % 60
        let hoursLeft = (nextInterval / 3600)
        
        // set formatted strings using the calculated times
        var formattedTime =  String(format: "%02d:%02d:%02d", hoursLeft, minutesLeft, secondsLeft)
        timeRemainingLabel.text = "\(formattedTime)"
        var remainingValue: NSString = String(format: "%02d hours, %02d minutes and %02d seconds", hoursLeft, minutesLeft, secondsLeft)
        timeRemainingLabel.accessibilityValue = remainingValue as String
        
        setupSlider()
        if PodcastPlayer.sharedInstance.currentlyPlaying() {
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    // Play button, displays Play or Pause depending on state of audio
    @IBAction func PlayAudio(sender: UIButton) {
        PodcastPlayer.sharedInstance.toggle()
        if (PodcastPlayer.sharedInstance.currentlyPlaying()) {
            sender.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            sender.setTitle("Play", forState: UIControlState.Normal)
        }
    }
    
    // skip forward 30 seconds button
    @IBAction func SkipForward(sender: UIButton) {
        PodcastPlayer.sharedInstance.skipForward()
    }
    
    // skip backward 30 seconds
    @IBAction func SkipBack(sender: UIButton) {
        PodcastPlayer.sharedInstance.skipBack()
    }

}
