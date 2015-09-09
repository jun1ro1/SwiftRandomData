//
//  J1RandomData.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2014/09/15.
//  Copyright (c) 2014 OKU Junichirou. All rights reserved.
//

import Foundation
import Darwin

struct CharacterSets: OptionSetType, Hashable {
    let rawValue: UInt32

    init(rawValue: UInt32) { self.rawValue = rawValue }
    
    var hashValue: Int { return Int(self.rawValue) }

    static let ExclamationMark         = CharacterSets(rawValue: 0x00000001) // "!"
    static let QuotationMark           = CharacterSets(rawValue: 0x00000002) // '"'
    static let NumberSign              = CharacterSets(rawValue: 0x00000004) // "#"
    static let DollarSign              = CharacterSets(rawValue: 0x00000008) // "$"
    static let PercentSign             = CharacterSets(rawValue: 0x00000010) // "%"
    static let Ampersand               = CharacterSets(rawValue: 0x00000020) // "&"
    static let Apostrophe              = CharacterSets(rawValue: 0x00000040) // "'"
    static let Parenthesises           = CharacterSets(rawValue: 0x00000080) // "(", ")"
    static let Asterisk                = CharacterSets(rawValue: 0x00000100) // "*"
    static let PlusSign                = CharacterSets(rawValue: 0x00000200) // "+"
    static let Comma                   = CharacterSets(rawValue: 0x00000400) // ","
    static let HyphenMinus             = CharacterSets(rawValue: 0x00000800) // "-"
    static let FullStop                = CharacterSets(rawValue: 0x00001000) // "."
    static let Solidus                 = CharacterSets(rawValue: 0x00002000) // "/"
    static let Digits                  = CharacterSets(rawValue: 0x00004000) // "0".."9"
    static let Colon                   = CharacterSets(rawValue: 0x00008000) // ":"
    static let Semicolon               = CharacterSets(rawValue: 0x00010000) // ";"
    static let LessAndGreaterThanSigns = CharacterSets(rawValue: 0x00020000) // "<", ">"
    static let EqualsSign              = CharacterSets(rawValue: 0x00040000) // "="
    static let QuestionMark            = CharacterSets(rawValue: 0x00080000) // "?"
    static let CommercialAt            = CharacterSets(rawValue: 0x00100000) // "@"
    static let UppercaseLatinAlphabets = CharacterSets(rawValue: 0x00200000) // "A".."Z"
    static let SquareBrackets          = CharacterSets(rawValue: 0x00400000) // "[", "]"
    static let ReverseSolidus          = CharacterSets(rawValue: 0x00800000) // "\"
    static let CircumflexAccent        = CharacterSets(rawValue: 0x01000000) // "^"
    static let LowLine                 = CharacterSets(rawValue: 0x02000000) // "_"
    static let GraveAccent             = CharacterSets(rawValue: 0x04000000) // "`"
    static let LowercaseLatinAlphabets = CharacterSets(rawValue: 0x08000000) // "a".."z"
    static let CurlyBrackets           = CharacterSets(rawValue: 0x10000000) // "{", "}"
    static let VerticalLine            = CharacterSets(rawValue: 0x20000000) // "|"
    static let Tilde                   = CharacterSets(rawValue: 0x40000000) // "~"
    
    static let Base64                  = CharacterSets(
                [.Digits, .UppercaseLatinAlphabets, .LowercaseLatinAlphabets, .PlusSign, .Solidus]) // 0..9 A-Za-z + /
}

 let CharactersHash: [CharacterSets: String] = [
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

struct CharactersNumber: Hashable, Equatable {
    let rawValue: UInt32

    init(rawValue: UInt32) { self.rawValue = rawValue }

    var hashValue: Int { return Int(self.rawValue) }

    static let Hexadecimal = CharactersNumber(rawValue: 0x80000001)
}

func ==(lhs: CharactersNumber, rhs: CharactersNumber) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

let CharacterNumberHash: [CharactersNumber: String] = [
    .Hexadecimal: "0123456789ABCDEF"
]


enum CypherCharacters {
    case Characters(CharacterSets)
    case SpecialCharacters(CharactersNumber)
    
    func toString() -> String? {
        switch self {
        case .Characters(let s):
            var str = ""
            for (key,val) in CharactersHash {
                if s.contains(key) {
                    str += val
                }
            }
            return str
        case .SpecialCharacters(let s):
            return CharacterNumberHash[s]
        }
    }
    
}


/*
 let z = CypherCharacters.Characters(.Base64)
 let y = CypherCharacters.SpecialCharacters(.Hexadecimal)


 let xx: CypherCharacter = CypherCharacter( .ExclamationMark.rawValue & .NumberSign.rawValue )

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
*/

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
                    ++i
                }
        })
        

// data must be cleared for a security reason.

        return array
    }
    
    func getRandomString( length: Int, chars: CypherCharacters ) -> String? {
        
        if length <= 0 {
            return nil
        }
        
        guard let letters = chars.toString() else {
            return nil
        }
//        switch option {
//        case .Digits:
//            letters = DIGITS
//        case .HexDigits:
//            letters = HEXADECIMALS
//        case .UpperCaseLetters:
//            letters = DIGITS + UPPER_CASE_LETTERS
//        case .LowerCaseLetters:
//            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS
//        case .ArithmeticCharacters:
//            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS + ARITHMETIC_CHARACTERS
//        case .Punctations:
//            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS + PUNCTATIONS
//        default:
//            letters = DIGITS + UPPER_CASE_LETTERS + LOWER_CASE_LETTERS + PUNCTATIONS
//        }
        
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
            ++n
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
                ++ns
            }
        }
        
        return str
    }
    
}


