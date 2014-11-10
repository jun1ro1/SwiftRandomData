//
//  SiteEditViewController.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import UIKit
import CoreData

class SiteEditViewController: UITableViewController {

    var detailItem : NSManagedObject?
    
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textFieldURL:   UITextField!
    @IBOutlet weak var textFieldID:    UITextField!
    @IBOutlet weak var textFieldPass:  UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseID = ""
        
        switch indexPath.row {
        case 1  : reuseID = "CellTitle"
        case 1  : reuseID = "CellURL"
        case 2  : reuseID = "CellID"
        case 3  : reuseID = "CellPass"
        default : reuseID = ""
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        switch indexPath.row {
        case 0  : cell.textLabel.text = self.detailItem?.valueForKey("title")?.description
        case 1  : cell.textLabel.text = self.detailItem?.valueForKey("loginURL")?.description
        case 2  : cell.textLabel.text = self.detailItem?.valueForKey("loginID")?.description
        case 3  : cell.textLabel.text = self.detailItem?.valueForKey("loginPass")?.description
        default : cell.textLabel.text = "Error"
        }
        
        return cell
    }



    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }


    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
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
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


}
