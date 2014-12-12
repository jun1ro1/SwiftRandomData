//
//  MasterViewController.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import UIKit
import CoreData

class MasterViewCell: UITableViewCell {
    @IBOutlet var title: UILabel?
    @IBOutlet var url: UILabel?
    @IBOutlet var openButton: UIButton?
}

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var siteManager:          J1SiteManager = J1SiteManager.sharedManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.managedObjectContext = J1CoreDataManager.sharedInstance.managedObjectContext
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton

/*
        let context = self.fetchedResultsController.managedObjectContext
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Site", inManagedObjectContext: context) as NSManagedObject
        newManagedObject.setValue("http://www.apple.com/", forKey: "url")
        newManagedObject.setValue("Apple",                 forKey: "title")
        newManagedObject.setValue("jun1ro1",               forKey: "userid")
        newManagedObject.setValue("pass",                  forKey: "pass")
        
        var error: NSError?
        self.managedObjectContext?.save(&error)
*/
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSite" {
            // http://stackoverflow.com/questions/9339302/indexpath-for-segue-from-accessorybutton
            if let indexPath = self.tableView.indexPathForCell(sender as UITableViewCell) {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                (segue.destinationViewController as SiteViewController).detailItem = object
            }
        }
        else if segue.identifier == "EditSite" {
            let cdm = J1CoreDataManager.sharedInstance
            let context = cdm.managedObjectContext!
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Site", inManagedObjectContext: context) as NSManagedObject
            let vc = segue.destinationViewController as SiteViewController
            vc.detailItem = newManagedObject
            vc.setEditing(true, animated:false)
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MasterViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
/*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let obj = self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject {
            let urlstr = obj.valueForKey("url") as String
            if let url = NSURL(string: urlstr) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
    }
*/
/*
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier("ShowSite", sender: cell)
    }
*/

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        
        if let mcell = cell as? MasterViewCell {
            if let title = object.valueForKey("title")?.description {
                mcell.title?.text = title
            }
            if let url = object.valueForKey("url")?.description {
                mcell.url?.text = url
            }
            mcell.openButton?.addTarget(self, action: "tapped:", forControlEvents: .TouchDown)
       }
    }
    
    func addTarget(control: UIControl, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        var act: Selector?
        if let acts = control.actionsForTarget(self, forControlEvent: controlEvents) {
            for a in acts {
                if action == Selector(a as String) {
                    act = Selector(a as String)
                }
            }
        }
        if act == nil {
            control.addTarget(self, action: action, forControlEvents: controlEvents)
        }
        else {
            println("\(action.description) is already added for event \(controlEvents) in \(control)")
        }
        
    }

    func tapped(sender: AnyObject){
        if let button = sender as? UIButton {
            var v: UIView? = button
            do {
                v = v?.superview
            } while ( v != nil && !(v is UITableViewCell) )
            
            if let vv = v as? MasterViewCell {
                if let urlstr = vv.url?.text {
                    if let url = NSURL(string: urlstr) {
//                        if UIApplication.sharedApplication().canOpenURL(url) {
                            UIApplication.sharedApplication().openURL(url)
//                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
            }
            
            let fetchRequest = NSFetchRequest()
            // Edit the entity name as appropriate.
            let entity = NSEntityDescription.entityForName("Site", inManagedObjectContext: self.managedObjectContext!)
            fetchRequest.entity = entity
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            let sortDescriptors = [sortDescriptor]
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            var error: NSError? = nil
            if !_fetchedResultsController!.performFetch(&error) {
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

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
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


    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

    func insertNewObject(sender: AnyObject) {
        self.performSegueWithIdentifier("EditSite", sender: self)
    }
}

