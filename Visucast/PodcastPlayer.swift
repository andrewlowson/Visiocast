//
//  PodcastPlayer.swift
//  Visiocast
//
//  Class to control all operations pertaining to the Audio Player
//
//  Created by Andrew Lowson on 13/08/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation
import AVFoundation

class PodcastPlayer {

    static let sharedInstance = PodcastPlayer() // Create an instance I can access anywhere in the code
    
    private var player: AVAudioPlayer? // AudioPlayer object.
    private var isPlaying = false // boolean to find out if audio is currently playing
    private var filename: String?
    private var currentTime: NSTimeInterval = 0 // variable will be used to set current playback position
    
    let defaults = NSUserDefaults.standardUserDefaults() // persistant storage area, track playback position is read from and written to here.

    func play() {
        if isPlaying {
            pause() // if audio is playing, call pause function
        } else {
            player!.prepareToPlay() //preloads buffer to prevent lag
            player!.play() // play audio file
            isPlaying = true // tell system audio is now playing.
        }
    }
    
    /**
     *   Function pauses audio and stores playback
     *   This is in case we lose memory, the app crashes or is closed/quit by the user
    **/
    func pause() {
        player!.pause()
        isPlaying = false
        self.currentTime = player!.currentTime // take the current playback position, store it
        defaults.setObject(currentTime, forKey: filename!) // write playback position, in case we never play again in this instance
    }
    
    // stop audio
    func stop() {
        player!.stop()
        isPlaying = false
    }
    
    /**
        Function used by remote controls to toggle playback
    **/
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    /**
     *   Method to create the audio assets and prepare the app for playback
    **/
    func prepareAudio(myData: NSData, filename: String) {
        self.filename = filename
        
        do {
            player = try AVAudioPlayer(data: myData, fileTypeHint: nil)
            player!.prepareToPlay()
            
            // If we've started this podcast before, go and get it's playback position
            if let time = defaults.objectForKey(filename) as? NSTimeInterval {
                currentTime = time
                player!.currentTime = time
            } 
            player!.play()
            isPlaying = true
        } catch {
            print("something went wrong with Player Line 66")
        }
    }
    
    /**
     *   Accessor function for currently playing variable
    **/
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
    /**
     *   Set playback position +30 seconds from now
    **/
    func skipForward() {
        currentTime = player!.currentTime
        currentTime = currentTime + 30
        player!.currentTime = currentTime
    }
    
    /**
     *   Set playback position -30 seconds
    **/
    func skipBack() {
        currentTime = player!.currentTime
        currentTime = currentTime - 30
        player!.currentTime = currentTime
    }
    
    func getTime() -> NSTimeInterval {
        return player!.currentTime
    }
    
    func setTime(newTime: NSTimeInterval) {
        currentTime = newTime
        player!.currentTime = newTime
    }
    
    func duration() -> NSTimeInterval {
        return player!.duration // get file length in seconds
    }
}