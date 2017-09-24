//
//  J1SiteManager.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

var sJ1SiteManager: J1SiteManager? = nil

class J1SiteManager {

    class func sharedManager()->J1SiteManager {
        if sJ1SiteManager == nil {
            sJ1SiteManager = J1SiteManager()
        }
        return sJ1SiteManager!
    }
    
    func insertNewObject(sender: AnyObject) {
        let cdm = J1CoreDataManager.sharedInstance
        let context = cdm.managedObjectContext!
        _ = NSEntityDescription.insertNewObject(forEntityName: "Site", into: context) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        /*/
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //println("Unresolved error \(error), \(error.userInfo)")
        abort()
        }
        */
    }

}
