//
//  J1ManagedObjectProxy.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2015/02/01.
//  Copyright (c) 2015年 OKU Junichirou. All rights reserved.
//

import Foundation
import CoreData

class J1ManagedObjectProxy {

    // MARK: - properties
    var managedObject: NSManagedObject
    var hasChanges: Bool {
        get {
            return self._changed
        }
    }
    
    // MARK: - private instance variables
    private var _attributes: [ String: AnyObject ]
    private var _changed: Bool
    
    // MARK: - life cycle
    init(managedObject: NSManagedObject) {
        self.managedObject = managedObject
        self._attributes   = [:]
        self._changed      = false
        self.reload()
    }
    
    // MARK: - public methods
    func reload() {
        self._changed = false
        let entity: NSEntityDescription = self.managedObject.entity;
        _ = Array( entity.attributesByName.keys ).map {
            self._attributes[$0 as String] = self.managedObject.primitiveValue(forKey: $0 as String) as AnyObject
        }
    }
    
    func writeBack(closure: (NSObject, AnyObject)->Void) {
        self._changed = false
        for (key, val) in self._attributes {
            self.managedObject.setValue(val, forKey: key)
            closure(key as NSObject, val)
        }
    }
    
    func setValue(value: AnyObject?, forKey key: String) {
        self._attributes[key] = value
        self._changed = true
    }
    
    func valueForKey(key: String) -> AnyObject? {
        return self._attributes[ key ]
    }
}
