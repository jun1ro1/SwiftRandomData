//
//  Site.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/12/18.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

@objc(Site)

class Site: NSManagedObject {

    @NSManaged var active: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var length: NSNumber
    @NSManaged var loginAt: NSDate
    @NSManaged var memo: String
    @NSManaged var option: NSNumber
    @NSManaged var pass: String
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var userid: String
    @NSManaged var selectAt: NSDate
    @NSManaged var uuid: String
    @NSManaged var passwords: NSSet
    @NSManaged var selecting: Password

}

// http://stackoverflow.com/questions/25291760/swift-and-coredata-problems-with-relationship-nsset-nsset-intersectsset
extension Site {
    override func awakeFromInsert() {
        self.setPrimitiveValue(NSDate(), forKey: "createdAt")
        self.setPrimitiveValue(4, forKey: "length")
        self.setPrimitiveValue(NSUUID().UUIDString, forKey: "uuid")
    }
    
    func addPasswordObject( pass: Password ){
        var array = self.passwords.allObjects as [Password]
        array.append( pass )
        self.passwords = NSSet(array: array)
    }
    
    func removePasswordObject( pass: Password ){
        var array = self.passwords.allObjects as [Password]
        if let index = find( array, pass ) {
            array.removeAtIndex(index)
        }
    }
}


