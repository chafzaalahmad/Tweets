//
//  SearchTweetViewController.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import UIKit

/// Search Tweets from Twitter server and display into TableView , user can also save tweets
class SearchTweetViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    ///List of all search tweets
    var tweetDataSource : [Tweet] = []
    
    /// Use for Twitter calls
    let objTweetServices = TweetServices()
    
    var resultSearchController : UISearchController?
    
    /// handle Twitter search response
    var tweetSearchCompletion : TweetCompletionBlock?
    
    /// Use for block duplicate search calls
    var lastSearchText : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Self Sizing Cells and Dynamic
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
        
        /**
        *  set navigationbar title color
        */
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.returnKeyType = UIReturnKeyType.Done
            controller.searchBar.delegate = self
            
            self.tableView.tableHeaderView = controller.searchBar
            
            
            return controller
        })()
        
        definesPresentationContext = true
        
        /// handle Twitter search response and update table view base on block data
        self.tweetSearchCompletion = { (tweets, error) -> Void in
            if let err = error{
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.tweetDataSource = []
                    self.tableView.reloadData()

                    /**
                    *  error code -999 = cancel request programatically
                    *  ignore error -999
                    */
                    if(err.code != -999){
                        if(self.resultSearchController!.searchBar.becomeFirstResponder()){
                            self.resultSearchController!.searchBar.resignFirstResponder()
                        }
                        
                        Utilities.showError(err, controller: self)
                    }

                    
                })
            }
            else if let searchTweets = tweets{
                /// in swift reload data not call "cell for row" since add main thread
                dispatch_async(dispatch_get_main_queue(),{
                    self.tweetDataSource = searchTweets
                    self.tableView.reloadData()
                })
            }
        }
        
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(self.resultSearchController!.searchBar.becomeFirstResponder()){
            self.resultSearchController!.searchBar.resignFirstResponder()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetDataSource.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        let tweet = self.tweetDataSource[indexPath.row]
        
        cell.configureView(tweet.name, tweetText: tweet.text, profileImageUrl: tweet.profileImage)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        /// Configure right swipe button action and add save tweet logic
        let save = UITableViewRowAction(style: .Normal, title: "Save") { action, index in
            let tweet = self.tweetDataSource[indexPath.row]
            self.saveTweet(tweet)
            self.tableView.editing=false;
        }
        save.backgroundColor = UIColor(red: 0/256, green: 132/256, blue: 180/256, alpha: 1)
        
        return [save]
    }
    
    /** UISearchResultsUpdating handler
        search tweets when user type text
     */
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        if let searchText = searchController.searchBar.text{
            self.searchTweets(searchText)
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    /**
     Search tweets using TweetServices object
     
     - parameter searchText: search text
     */
    func searchTweets(searchText : String){
        
        if (searchText.isEmpty){
            self.objTweetServices.cancelRequest()
            lastSearchText = ""
            self.tweetDataSource = []
            self.tableView.reloadData()
            return
        }
        else if(lastSearchText != searchText)
        {
            lastSearchText = searchText
            objTweetServices.getTweets(["q" : searchText, "count" : Twitter.TweetsPerPage], completion: self.tweetSearchCompletion)
        }
        
    }
    
    /**
     Save Tweet to Core Data
     
     - parameter tweetToDelete: save this tweet to code data
     */
    func saveTweet(tweetToSave : Tweet?){
        if let tweet = tweetToSave{
            var tweetCD : CDTweet? = CDTweet.findByID(tweet.id!.intValue) as? CDTweet
            if(tweetCD == nil){
                tweetCD = CDTweet.create() as? CDTweet
            }
            print(tweetCD?.id?.intValue)
            tweetCD?.initWithTweetModel(tweet)
            
            CoreDataStack.sharedStack.saveContext()
        }
        
    }
    
    
}
