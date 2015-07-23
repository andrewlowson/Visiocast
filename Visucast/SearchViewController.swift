//
//  SearchViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var friendsArray = [FriendItem]()
    var filteredFriends = [FriendItem]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendsArray += [FriendItem(name: "Andrew Lowson")]
        self.friendsArray += [FriendItem(name: "Marco Cook")]
        self.friendsArray += [FriendItem(name: "iTunes")]
        self.friendsArray += [FriendItem(name: "iPhone")]
        self.friendsArray += [FriendItem(name: "Mac")]
        self.friendsArray += [FriendItem(name: "Gary Whittington")]

        self.searchResultsTableView?.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
