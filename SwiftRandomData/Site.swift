//
//  Site.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/11/15.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

// @objc(Site)

class Site: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var memo: String
    @NSManaged var pass: String
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var userid: String
    @NSManaged var length: NSNumber
    @NSManaged var option: NSNumber
    @NSManaged var passwords: NSSet

}
