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
    
    var currentTime: NSTimeInterval = 0
    
    func play() {
        println(isPlaying)
        if isPlaying {
            pause()
        }
        player!.play()
        isPlaying = true
    }
    
    func pause() {
        player!.pause()
        isPlaying = false
        self.currentTime = player!.currentTime
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    func prepareAudio(myData: NSData) {
        player = AVAudioPlayer(data: myData, error: nil)
        player!.prepareToPlay()
        player!.play()
        isPlaying = true
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
}