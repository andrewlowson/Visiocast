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
        aboutParagraph.text = "asdfasf"
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var AboutTabBarItem: UITabBarItem!
}



extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}
