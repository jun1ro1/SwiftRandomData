//
//  Password.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

class Password: NSManagedObject {

    @NSManaged var length: NSNumber
    @NSManaged var option: NSNumber
    @NSManaged var pass: String
    @NSManaged var created: NSDate
    @NSManaged var relationship: NSManagedObject

}
