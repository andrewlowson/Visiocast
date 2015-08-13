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

    static let sharedInstance = PodcastPlayer(podcast: NSData())
    
    private var player: AVAudioPlayer?
    private var isPlaying = false

    
    init(podcast: NSData) {
        prepareAudio(podcast)
    }
    
    func play() {
        player!.play()
        isPlaying = true
    }
    
    func pause() {
        player!.pause()
        isPlaying = false
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
    }
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
}