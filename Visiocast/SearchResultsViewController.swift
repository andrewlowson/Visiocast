//
//  SearchResultsViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController
{
    let appleProducts = ["iMac", "iPhone", "Apple Watch", "iPod", "iPad", "AppleTV", "Mac Pro"]
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.resultSearchController = UISearchController(searchResultsController: nil)
//        //self.resultSearchController.searchResultsUpdater = self
//        
//        self.resultSearchController.dimsBackgroundDuringPresentation = false
//        self.resultSearchController.searchBar.sizeToFit()
//        
//        self.tableView.tableHeaderView = self.resultSearchController.searchBar
//        
//        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBOutlet weak var SearchTabBarItem: UITabBarItem!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
