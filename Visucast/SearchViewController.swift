//
//  SearchViewController.swift
//  Visucast
//
//  Created by Andrew Lowson on 19/07/2015.
//  Copyright (c) 2015 Andrew Lowson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController, UISearchBarDelegate {
    /**
     *  Things that need to be done in this View:
     *      - Text inside the search bar needs to be captured, turned lower case
     *      - JSON needs to be parsed, feedURL, artworkURL, collectionName
     *      - TableView Updated
     *      - Segue prepare function
    **/
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    
    
    var podcasts = [[Podcast]]()
    
    private var lastSuccessfulRequest: SearchRequest?
    private var nextRequestToAttempt: SearchRequest? {
        return nil
    }
    
    var searchText: String? = "Search for Podcasts" {
        didSet {
            lastSuccessfulRequest = nil
            searchBar.text = searchBar.placeholder
            podcasts.removeAll()
            tableView.reloadData()
            searchBarSearchButtonClicked(searchBar)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        println("I loaded")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     //
    }
    
    private func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //
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
