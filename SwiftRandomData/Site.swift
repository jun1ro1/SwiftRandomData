//
//  Site.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

class Site: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var userid: String
    @NSManaged var created: NSDate
    @NSManaged var passwords: Password

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
//        self.setPrimitiveValue(NSDate.date(), forKey: "createdAt")
    }
}
