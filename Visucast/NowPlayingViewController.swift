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
    var episodeTitle: String?
    //var episodePath = NSFileManager.documentsDirectoryPath() + episodeTitle!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    //var ButtonAudioURL = NSURL(fileURLWithPath: NSSearchPathDirectory.DocumentDirectory
    var isAudioPlaying = false
    
    // not in use
    var nowPlaying: AVAsset?
    
    var podcastFile: NSData?
    
    var myPlayer = AVAudioPlayer()
    var podcastArtwork: UIImage?
    
    @IBOutlet weak var artworkImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.prepareAudio(podcastFile!)
        self.myPlayer.play()
        isAudioPlaying = true
        playButton.setTitle("Pause", forState: UIControlState.Normal)
        artworkImageView.image = podcastArtwork!
        episodeTitleLabel.text = episodeTitle!
        
        
        
        //ButtonAudioPlayer = AVAudioPlayer(contentsOfURL: self.ButtonAudioURL, error: nil)

        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareAudio(myData: NSData) {
        myPlayer = AVAudioPlayer(data: myData, error: nil)
        myPlayer.prepareToPlay()
    }
    
    
    @IBAction func PlayAudio(sender: UIButton) {
        if (isAudioPlaying) {
            println(isAudioPlaying)
            myPlayer.pause()
            isAudioPlaying = false
            sender.setTitle("Play", forState: UIControlState.Normal)
        } else {
            myPlayer.play()
            isAudioPlaying = true
            sender.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    func playAudio() {
        
    }
    
    @IBOutlet weak var playButton: UIButton!{
        didSet{
            if self.isAudioPlaying {
                playButton.setTitle("Pause", forState: UIControlState.Normal)
            } else {
                playButton.setTitle("Play", forState: UIControlState.Normal)
            }
        }
    }
    @IBAction func SkipForward(sender: UIButton) {
        
    }
    
    
    @IBAction func SkipBack(sender: UIButton) {
        
        
    }
    
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
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

