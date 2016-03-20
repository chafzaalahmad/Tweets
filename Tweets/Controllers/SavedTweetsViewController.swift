//
//  SavedTweetsViewController.swift
//  Tweets
//
//  Created by Afzaal on 19/03/2016.
//  Copyright © 2016 DevCrew. All rights reserved.
//

import UIKit
import CoreData

/// Display all core data save tweets , user can delete tweet from core data
class SavedTweetsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButtonItem = self.editButtonItem()
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

        tableView.tableFooterView = UIView()
        
        ///Self Sizing Cells and Dynamic
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /**
        *  set navigationbar title color
        */
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]

    }
    
    /// Tweets Data source for table view
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let manageObjectContext = CoreDataStack.sharedStack.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: CDTweet.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: manageObjectContext, sectionNameKeyPath: "id", cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }
        catch{
            
        }
        
        return fetchedResultsController
        
    }()
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return (sectionInfo.numberOfObjects)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        if let tweet = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDTweet{
            cell.configureView(tweet.name, tweetText: tweet.text, profileImageUrl: tweet.profileImage)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return self.editing ? .Delete : .None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            /// Delete tweet from core data
            if let tweet = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDTweet{
                tweet.deleteMe()
            }
        }
    }
    
    // MARK: - NSFetchedResultsControlle
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type){
            
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        default:
            break
            
        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        let tableView = self.tableView
        
        if(indexPath == nil)
        {
            tableView.reloadData()
            return
        }
        
        switch(type){
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break
            
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break
            
        case NSFetchedResultsChangeType.Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break
            
        case NSFetchedResultsChangeType.Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
            break
            
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
}
