//
//  Algorithm.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2015/01/02.
//  Copyright (c) 2015年 OKU Junichirou. All rights reserved.
//

import Foundation

// MARK: - Utility functions

func unique<T: Equatable>(array: [T]) -> [T] {
    var result = [T]()
    
    for elm in array {
        if result.index(of: elm) == nil {
            result += [elm]
        }
    }
    return result
}

func difference<T: Equatable>(x: [T], y: [T]) -> [T] {
    return x.filter {y.indexOf($0) == nil}
}

func intersection<T: Equatable>(x: [T], y: [T]) -> [T] {
    return x.filter {y.indexOf($0) == nil ? false : true}
}

