//
//  ViewController.swift
//  SwiftTableView
//
//  Created by Adam Cooper on 1/8/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UISearchBarDelegate {
    
    var sampleArray = []
    var searchTerm = "Happy"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "The TableView"
        self.navigationController?.navigationBar.barTintColor = UIColor.greenColor()
        self.navigationController?.navigationBar.translucent = false
        
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.searchItunesFor("DRAFT")

    }
    
    func refresh(sender:AnyObject)
    {
        searchItunesFor(searchTerm)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTerm = self.searchBar.text
        searchItunesFor(searchTerm)
    }
    
    
    
    func searchItunesFor(searchTerm: String) {
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err) as NSDictionary
                
                
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                
                let results: NSArray = jsonResult["results"] as NSArray
                dispatch_async(dispatch_get_main_queue(), {
                    self.sampleArray = results
                    self.tableView!.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            })
            
            task.resume()
        }
        
    }
    
    
//# MARK: - TableView DataSource
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }

//# MARK: - TableView DataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sampleArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cell"
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:reuseIdentifier)
        let rowData: NSDictionary = self.sampleArray[indexPath.row] as NSDictionary
        
        cell.textLabel?.text = rowData["trackName"] as? String
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString: NSString = rowData["artworkUrl60"] as NSString
        let imgURL: NSURL? = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        let imgData = NSData(contentsOfURL: imgURL!)
        cell.imageView?.image = UIImage(data: imgData!)
        
        // Get the formatted price string for display in the subtitle
        let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        cell.detailTextLabel?.text = formattedPrice
        
        return cell
    }
    
}

