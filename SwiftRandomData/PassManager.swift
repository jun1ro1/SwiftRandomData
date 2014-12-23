//
//  PassManager.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/11/24.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

var sPassManager: PassManager? = nil
let ENTITY_PASS = "Password"

class PassManager {
    
    class func sharedManager()->PassManager {
        if sPassManager == nil {
            sPassManager = PassManager()
        }
        return sPassManager!
    }
    
    var _managedObjectContext: NSManagedObjectContext? = nil
    init() {
        self._managedObjectContext = J1CoreDataManager.sharedInstance.managedObjectContext
    }
    
    func create( site:Site? )->Password {
        let cdm = J1CoreDataManager.sharedInstance
        let context = cdm.managedObjectContext!
        let obj
            = NSEntityDescription.insertNewObjectForEntityForName(ENTITY_PASS, inManagedObjectContext: context)
                as Password
        obj.setPrimitiveValue(true ,    forKey: "active")
        obj.setPrimitiveValue(NSDate(), forKey: "createdAt")
        if site != nil {
            obj.site = site!
            obj.setPrimitiveValue(site!, forKey: "site")
            site?.addPasswordObject(obj)
        }
        return obj
    }
    
    func dispose(obj:Password) {
        obj.active = false
    }
    
    func delete(obj:Password) {
        obj.site.removePasswordObject(obj)
        let context = self._managedObjectContext
        context!.deleteObject(obj)
        
        var error: NSError? = nil
        if context!.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    func select(obj:Password, site:Site) {
        site.selecting = obj
        site.pass = obj.pass
    }
}
