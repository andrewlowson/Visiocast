//
//  AboutViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var aboutParagraph: UITextView!
    
    @IBOutlet weak var imageLogoView = UIImageView()
    
    @IBOutlet weak var dictateButton: UIButton! {
        didSet{
            let image = UIImage(named: "microphoneIcon") as UIImage!
            let dictateButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            dictateButton.setImage(image, forState: .Normal)
            dictateButton.setTitle("Dictate", forState: .Normal)
        }
    }
    
    var image: UIImage? {
        get { return imageLogoView?.image }
        set { imageLogoView?.image = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aboutParagraph.editable = false
        // Do any additional setup after loading the view.
        let logoImage = UIImage(named: "glasgowLogo")
        view.addSubview(self.imageLogoView!)
        scrollView.addSubview(aboutParagraph)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var aspectRatioConstraint: NSLayoutConstraint? {
        willSet {
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet {
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }  
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
        {
        didSet {
            aboutParagraph.text = "Welcome to Visiocast. \n \nVisiocast is a Podcast application built for people who are visually impaired. \nThere is a global button at the top for you to dictate commands, like 'Download The Empire Podcast' or 'search for Back to Work.' \n \nVisiocast started as a Software Development Masters project out of the University of Glasgow in the summer of 2015.\n \nContact:\nAndrew Lowson: andrew@lowson.co \nChuan Chen: 2122015C@student.gla.ac.uk"
        }
    }

    @IBOutlet weak var AboutTabBarItem: UITabBarItem!
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}
