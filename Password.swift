//
//  Password.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/12/18.
//  Copyright (c) 2014年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

@objc(Password)

class Password: NSManagedObject {

    @NSManaged var active: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var pass: String
    @NSManaged var selectedAt: NSDate
    @NSManaged var uuid: String
    @NSManaged var site: Site

}
