//
//  PodcastPlayer.swift
//  Visiocast
//
//  Created by Andrew Lowson on 13/08/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import Foundation
import AVFoundation

class PodcastPlayer {

    static let sharedInstance = PodcastPlayer()
    
    private var player: AVAudioPlayer?
    private var isPlaying = false
    let defaults = NSUserDefaults.standardUserDefaults()
    var filename: String?
    
    var currentTime: NSTimeInterval = 0
    
    
    func play() {
        if isPlaying {
            pause()
        } else {
            player!.prepareToPlay()
            player!.play()
            isPlaying = true
        }
    }
    
    func pause() {
        player!.pause()
        isPlaying = false
        self.currentTime = player!.currentTime
        defaults.setObject(currentTime, forKey: filename!)
    }
    
    func stop() {
        player!.stop()
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    func prepareAudio(myData: NSData, filename: String) {
        self.filename = filename
        player = AVAudioPlayer(data: myData, error: nil)
        player!.prepareToPlay()
        if let time = defaults.objectForKey(filename) as? NSTimeInterval {
            currentTime = time
            player!.currentTime = time
        } 
        player!.play()
        isPlaying = true
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
    func skipForward() {
        currentTime = player!.currentTime
        println(currentTime)
        currentTime = currentTime + 30
        player!.currentTime = currentTime
    }
    
    func skipBack() {
        currentTime = player!.currentTime
        println(currentTime)
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
        return player!.duration
    }
}