//
//  J1RandomData.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014 OKU Junichirou. All rights reserved.
//

import Swift
import Foundation
import Darwin


struct CypherCharacters: OptionSetType, Hashable {
    let rawValue: UInt32
    
    init(rawValue: UInt32) { self.rawValue = rawValue }
    
    var hashValue: Int { return Int(self.rawValue) }
    
    static let ExclamationMark         = CypherCharacters(rawValue: 0x00000001) // "!"
    static let QuotationMark           = CypherCharacters(rawValue: 0x00000002) // '"'
    static let NumberSign              = CypherCharacters(rawValue: 0x00000004) // "#"
    static let DollarSign              = CypherCharacters(rawValue: 0x00000008) // "$"
    static let PercentSign             = CypherCharacters(rawValue: 0x00000010) // "%"
    static let Ampersand               = CypherCharacters(rawValue: 0x00000020) // "&"
    static let Apostrophe              = CypherCharacters(rawValue: 0x00000040) // "'"
    static let Parenthesises           = CypherCharacters(rawValue: 0x00000080) // "(", ")"
    static let Asterisk                = CypherCharacters(rawValue: 0x00000100) // "*"
    static let PlusSign                = CypherCharacters(rawValue: 0x00000200) // "+"
    static let Comma                   = CypherCharacters(rawValue: 0x00000400) // ","
    static let HyphenMinus             = CypherCharacters(rawValue: 0x00000800) // "-"
    static let FullStop                = CypherCharacters(rawValue: 0x00001000) // "."
    static let Solidus                 = CypherCharacters(rawValue: 0x00002000) // "/"
    static let Digits                  = CypherCharacters(rawValue: 0x00004000) // "0".."9"
    static let Colon                   = CypherCharacters(rawValue: 0x00008000) // ":"
    static let Semicolon               = CypherCharacters(rawValue: 0x00010000) // ";"
    static let LessAndGreaterThanSigns = CypherCharacters(rawValue: 0x00020000) // "<", ">"
    static let EqualsSign              = CypherCharacters(rawValue: 0x00040000) // "="
    static let QuestionMark            = CypherCharacters(rawValue: 0x00080000) // "?"
    static let CommercialAt            = CypherCharacters(rawValue: 0x00100000) // "@"
    static let UppercaseLatinAlphabets = CypherCharacters(rawValue: 0x00200000) // "A".."Z"
    static let SquareBrackets          = CypherCharacters(rawValue: 0x00400000) // "[", "]"
    static let ReverseSolidus          = CypherCharacters(rawValue: 0x00800000) // "\"
    static let CircumflexAccent        = CypherCharacters(rawValue: 0x01000000) // "^"
    static let LowLine                 = CypherCharacters(rawValue: 0x02000000) // "_"
    static let GraveAccent             = CypherCharacters(rawValue: 0x04000000) // "`"
    static let LowercaseLatinAlphabets = CypherCharacters(rawValue: 0x08000000) // "a".."z"
    static let CurlyBrackets           = CypherCharacters(rawValue: 0x10000000) // "{", "}"
    static let VerticalLine            = CypherCharacters(rawValue: 0x20000000) // "|"
    static let Tilde                   = CypherCharacters(rawValue: 0x40000000) // "~"
    
    static let AlphaNumeric            = CypherCharacters(
        [.Digits, .UppercaseLatinAlphabets, .LowercaseLatinAlphabets]) // 0..9 A-Za-z
    static let UpperCaseLetters        = CypherCharacters(
        [.Digits, .UppercaseLatinAlphabets])
    static let LowerCaseLetters        =
        CypherCharacters.UpperCaseLetters.union(CypherCharacters.LowercaseLatinAlphabets)
    static let Base64                  = CypherCharacters.AlphaNumeric.union(CypherCharacters([.PlusSign, .Solidus]))// 0..9 A-Za-z + /
    static let ArithmeticCharacters    =
        CypherCharacters.AlphaNumeric.union(
            CypherCharacters([
                CypherCharacters.PlusSign,
                CypherCharacters.HyphenMinus,
                CypherCharacters.Asterisk,
                CypherCharacters.Solidus]))
    static let AlphaNumericSymbols     =
        CypherCharacters.AlphaNumeric.union(CypherCharacters([
            .ExclamationMark,
            .NumberSign,
            .DollarSign,
            .PercentSign,
            .Ampersand,
            .Asterisk,
            .PlusSign,
            .HyphenMinus,
            .Solidus,
            .Digits,
            .EqualsSign,
            .QuestionMark,
            .CommercialAt,
            .CircumflexAccent,
            .LowLine,
            .VerticalLine,
            .Tilde
            ]))
    
    func toString() -> String? {
        var str = ""
        for (key,val) in CharactersHash {
            if self.contains(key) {
                str += val
            }
        }
        return str
    }
    
    func distance(other:CypherCharacters) -> UInt32 {
        return self.exclusiveOr(other).rawValue
    }
}

func | (left: CypherCharacters, right: CypherCharacters) -> CypherCharacters {
    return left.union(right)
}

let CharactersHash: [CypherCharacters: String] = [
    .ExclamationMark:         "!",
    .QuotationMark:           "\"",
    .NumberSign:              "#",
    .DollarSign:              "$",
    .PercentSign:             "%",
    .Ampersand:               "&",
    .Apostrophe:              "'",
    .Parenthesises:           "()",
    .Asterisk:                "*",
    .PlusSign:                "+",
    .Comma:                   ",",
    .HyphenMinus:             "-",
    .FullStop:                ".",
    .Solidus:                 "/",
    .Digits:                  "0123456789",
    .Colon:                   ":",
    .Semicolon:               ";",
    .LessAndGreaterThanSigns: "<>",
    .EqualsSign:              "=",
    .QuestionMark:            "?",
    .CommercialAt:            "@",
    .UppercaseLatinAlphabets: "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    .SquareBrackets:          "[]",
    .ReverseSolidus:          "\\",
    .CircumflexAccent:        "^",
    .LowLine:                 "_",
    .GraveAccent:             "`",
    .LowercaseLatinAlphabets: "abcdefghijklmnopqrstuvwxyz",
    .CurlyBrackets:           "{}",
    .VerticalLine:            "|",
    .Tilde:                   "~"
]


class J1RandomData {
    
    func getRandomData( length: Int ) -> Bytes? {
        
        guard 0 < length && length < 1024 else {
            return nil
        }
        
        // http://blog.sarabande.jp/post/92199466318
        
        // allocate zeroed memory area whose size is length
        let data = NSMutableData(length: length)
        
        // generate a random data and write to the buffer
        guard SecRandomCopyBytes( kSecRandomDefault, length,
                            UnsafeMutablePointer<UInt8>(data!.bytes) ) == 0 else {
            return nil
        }
        
        // allocate a byte array whose size is length
        var array :Bytes = Bytes( count: length, repeatedValue: 0)
        
        var i = 0
        data!.enumerateByteRangesUsingBlock(
            { (bytes: UnsafePointer<Void>, range: NSRange, _) -> Void in
                let d = UnsafeBufferPointer( start: UnsafePointer<UInt8>( bytes ), count: range.length )
                for j in range.location..<range.length {
                    array[ i ] = d[ j ]
                    i += 1
                }
        })

        // data must be cleared for a security reason.
        data?.resetBytesInRange(NSRange(location: 0, length: length))

        return array
    }
    
    func getRandomString( length: Int, chars: CypherCharacters ) -> String? {
        
        if length <= 0 {
            return nil
        }
        
        guard let letters = chars.toString() else {
            return nil
        }
        
        var letterArray: [Character] = []
        for ch in letters.characters {
            letterArray.append( ch )
        }
        let numLetters = letterArray.count
        
        // calculate the enough size of random data
        var b = 1
        var n = 0
        while b < numLetters {
            b *= 2
            n += 1
        }
        
        let bytes = ( length * n + 7 ) / 8
        
        // get the random data whose size is bytes byte
        let data: Bytes? = getRandomData( bytes )
        
        if data == nil {
            return nil
        }
        
        let charArray: Bytes = convertBase( data!, base: UInt8( numLetters ) )
        
        var str = ""
        var ns  = 0
        for ch in charArray {
            if ns < length {
                str += String( letterArray[ Int( ch ) ] )
                ns += 1
            }
        }
        
        return str.characters.count == 0 ? nil : str;
    }
    
}


