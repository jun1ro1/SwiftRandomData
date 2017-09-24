//
//  Bytes.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014 OKU Junichirou. All rights reserved.
//

import Foundation

public typealias Bytes = [UInt8]

func isZero( vals: Bytes ) -> Bool {
    let len = vals.count
    var i   = 0
    while i < len && vals[ i ] == 0 {
        i += 1
    }
    return i >= len  // it is a zero if all elements are 0
}

func zerosuppress( vals: Bytes! ) -> Bytes {
    let len = vals.count
    var i   = 0
    while i < len && vals[ i ] == 0 {
        i += 1
    }
    if i >= len {
        // all 0
        return [ 0 ]
    }
    else {
        var newVals: Bytes = vals  //.unshare()
        for _ in 0..<i {
            newVals.remove(at: 0)
        }
        return newVals
    }
}

func / ( dividend: Bytes, divisor: UInt8 ) -> ( Bytes, UInt8 ) {
    if divisor == 0 {
        return ( [ 0 ], 0 )
    }
    let len = dividend.count
    if len <= 0 {
        return ( [ 0 ], 0 )
    }
    
    var quotient: Bytes = []
    
    var remainder = 0
    for val in dividend {
        let x = remainder * 0x100 + Int( val )
        quotient.append( (UInt8)( x / Int( divisor ) ) )
        remainder = x % Int( divisor )
    }
    return ( zerosuppress( vals: quotient ), UInt8( remainder ) )
}

func convertBase( vals: Bytes, base: UInt8 ) -> Bytes {
    var dividend = vals
    var newVals: Bytes = []
    while !isZero( vals: dividend ) {
        let ( quotient, remainder ) = dividend / base
        newVals.append( remainder )
        dividend = quotient
    }
    if isZero( vals: newVals ) {
        return [ 0 ]
    }
    else {
        return newVals.reversed()
    }
}
