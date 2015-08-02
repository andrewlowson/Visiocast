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
    var episodeTitle: String = ""
    //var episodePath = NSFileManager.documentsDirectoryPath() + episodeTitle!
    
    //var ButtonAudioURL = NSURL(fileURLWithPath: NSSearchPathDirectory.DocumentDirectory
    var isAudioPlaying: Bool = false
    
    var ButtonAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //isAudioPlaying = true
        playAudio()
        
        //ButtonAudioPlayer = AVAudioPlayer(contentsOfURL: self.ButtonAudioURL, error: nil)

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func PlayAudio(sender: UIButton) {
        if (isAudioPlaying) {
            ButtonAudioPlayer.stop()
            !isAudioPlaying
            sender.setTitle("Play", forState: UIControlState.Normal)
            
        } else {
            ButtonAudioPlayer.play()
            !isAudioPlaying
            sender.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    func playAudio() {
    }
    
    @IBAction func SkipForward(sender: UIButton) {
        
    }
    
    
    @IBAction func SkipBack(sender: UIButton) {
        
        
    }
    
    
    
    @IBOutlet weak var shareButton: UIButton!
   
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

