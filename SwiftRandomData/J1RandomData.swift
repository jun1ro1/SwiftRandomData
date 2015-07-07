//
//  J1RandomData.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014 OKU Junichirou. All rights reserved.
//

import Foundation
import Darwin

let DIGITS                = "0123456789";
let HEXADECIMALS          = "0123456789ABCDEF"
let UPPER_CASE_LETTERS    = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let LOWER_CASE_LETTERS    = "abcdefghijklmnopqrstuvwxyz";
let ARITHMETIC_CHARACTERS = "*+-/"
let PUNCTATIONS           = "!\"#$%&'()*+,-./:;<=>?{|}~";


enum J1RandomOption: Int {
    case Digits
    case HexDigits
    case UpperCaseLetters
    case LowerCaseLetters
    case ArithmeticCharacters
    case Punctations
    case OptionsEnd
    
    func toString() -> String {
        var str = ""
        
        switch self {
        case .Digits:
            str = "0-9"
        case .HexDigits:
            str = "0-A-F"
        case .UpperCaseLetters:
            str = "0-A-Z"
        case .LowerCaseLetters:
            str = "0-Z a-z"
        case .ArithmeticCharacters:
            str = "0-z *+-/"
        case .Punctations:
            str = "0-z *(){}"
        default:
            str = "???"
        }
        return str
    }
}

class J1RandomData {
    
    func getRandomData( length: Int ) -> (Bytes?) {
        
        if length <= 0 {
            return nil
        }
        
        if length > 1024 {
            return nil
        }
        
        // http://blog.sarabande.jp/post/92199466318
        
        // allocate zeroed memory area whose size is length
        var data = NSMutableData( length: length )
        var ptr  = UnsafeMutablePointer<Byte>( data!.bytes )
        
        // generate a random data and write to the buffer
        let result: CInt = SecRandomCopyBytes(kSecRandomDefault, UInt( length ), ptr)
        if result != 0 {
            return nil
        }
        
        // allocate a byte array whose size is length
        var array: Bytes = Bytes( count: length, repeatedValue: 0)
        
        var i = 0
        data!.enumerateByteRangesUsingBlock(
            { (bytes: UnsafePointer<Void>, range: NSRange, _) -> Void in
                let d = UnsafeBufferPointer( start: UnsafePointer<Byte>( bytes ), count: range.length )
                for j in range.location..<range.length {
                    array[ i ] = d[ j ]
                    ++i
                }
        })
        

// data must be cleared for a security reason.

        return array
    }
    
    func getRandomString( length: Int, option: J1RandomOption ) -> String? {
        
        if length <= 0 {
            return nil
        }
        
        var letters: String = ""
        switch option {
        case .Digits:
            letters = DIGITS
        case .HexDigits:
            letters = HEXADECIMALS
        case .UpperCaseLetters:
            letters = DIGITS + UPPER_CASE_LETTERS
        case .LowerCaseLetters:
            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS
        case .ArithmeticCharacters:
            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS + ARITHMETIC_CHARACTERS
        case .Punctations:
            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS + PUNCTATIONS
        default:
            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS + PUNCTATIONS
        }
        
        var letterArray: [Character] = []
        for ch in letters {
            letterArray.append( ch )
        }
        let numLetters = letterArray.count
        
        // calculate the enough size of random data
        var b = 1
        var n = 0
        while b < numLetters {
            b *= 2
            ++n
        }
        
        let bytes = ( length * n + 7 ) / 8
        
        // get the random data whose size is bytes byte
        var data: Bytes? = getRandomData( bytes )
        
        if data == nil {
            return nil
        }
        
        let charArray: Bytes = convertBase( data!, Byte( numLetters ) )
        
        var str = ""
        var ns  = 0
        for ch in charArray {
            if ns < length {
                str += String( letterArray[ Int( ch ) ] )
                ++ns
            }
        }
        
        return str
    }
    
}


