//
//  PassViewController.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/11/24.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import UIKit
import CoreData

class PassViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var context: Site?
    
    var _managedObjectContext: NSManagedObjectContext? = nil
    
    var selected: Password? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self._managedObjectContext = J1CoreDataManager.sharedInstance.managedObjectContext
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.selected = self.context!.selecting
    }
    
    override func viewWillAppear(animated: Bool) {
   
        super.viewWillAppear(animated)
/*
        var error: NSError? = nil
        if !self.fetchedResultsController.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
*/
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    /*
        if let pass = self.selected {
            self.passManager.select(pass, site: self.context!)
        }
        if let moc = self._managedObjectContext {
            if moc.hasChanges {
                var error: NSError? = nil
                if !moc.save(&error) {
                    abort()
                }
            }
        }
    */
    }
    
    var passManager = PassManager.sharedManager()
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
//        println("PassViewController num. of rows = \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let pass = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Password
        cell.textLabel?.text = pass.pass
        cell.detailTextLabel?.text = (pass.createdAt as NSDate).descriptionWithLocale(nil)
        cell.accessoryType = ( pass == self.selected ) ? .Checkmark : .None
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell-pass", forIndexPath: indexPath) as UITableViewCell

        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let oldIndexPath = self.fetchedResultsController.indexPathForObject(self.selected!)!
        var indexPaths = [indexPath]
        indexPaths.append(oldIndexPath)
        indexPaths = unique(indexPaths)
        let pass = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Password
        
        self.selected = pass
//        self.context!.selecting = pass
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        self.passManager.select(pass, site: self.context!)

        if let moc = self._managedObjectContext {
            if moc.hasChanges {
                var error: NSError? = nil; _ = error
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    abort()
                }
            }
        }

      
        self.performSegueWithIdentifier("UnwindToSiteView", sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    

    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName(ENTITY_PASS, inManagedObjectContext: self._managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        _ = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Predicate
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [ "site", self.context!])
        fetchRequest.predicate = predicate
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self._managedObjectContext!, sectionNameKeyPath: nil, cacheName: "PassManager")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        NSFetchedResultsController.deleteCacheWithName(nil)
        
        var error: NSError? = nil; _ = error
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    private var _fetchedResultsController: NSFetchedResultsController? = nil
   
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
