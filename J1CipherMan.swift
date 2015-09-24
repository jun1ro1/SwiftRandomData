//
//  J1CipherMan.swift
//  SwiftRandomData
//
//  Created by OKU Junichirou on 2015/09/21.
//  Copyright © 2015年 OKU Junichirou. All rights reserved.
//

import Foundation

class J1CipherMan {
    static let sharedIncetance = J1CipherMan()
    
    lazy var _saltBin: Bytes?  = nil
    lazy var _saltStr: String? = nil
    var      _passPhrase       = NSString(string: "PassPhrase")
    var      _kek              = NSMutableData(length: 32)
    
    
    let saltLength = 16;
    
    var randgen = J1RandomData()

    init() {
        _saltBin = self.randgen.getRandomData(saltLength)
        guard _saltBin != nil else {
            return
        }
        
        let ptr = UnsafeBufferPointer(start: _saltBin!, count: (_saltBin?.count)!)
        self._saltStr = NSData(bytes: ptr.baseAddress, length: (_saltBin?.count)!)
            .base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        var data = NSMutableData(bytes: ptr.baseAddress, length: (_saltBin?.count)!)
        data.appendData(
            NSData(bytes: _passPhrase.UTF8String,length: _passPhrase.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        
        // http://www.iteachcoding.com/how-to-hmac-sha1-sign-an-api-request-using-swift
        // http://spin.atomicobject.com/2015/02/23/c-libraries-swift/
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))
        var passData = self._passPhrase.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
            passData!.bytes, passData!.length, data.bytes, data.length, result!.mutableBytes)
        self._kek = result!
        print("CCHmac = \(result?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))")
        
        var res = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                        UnsafePointer<Int8>(passData!.bytes), passData!.length,
                        UnsafePointer<UInt8>(data.bytes), data.length,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                        1,
                        UnsafeMutablePointer<UInt8>(result!.mutableBytes), result!.length)
       
        print("CCKeyDerivationPBKDF:res = \(res):\(result?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))")
        
        data = NSMutableData(bytes: ptr.baseAddress, length: (_saltBin?.count)!)
        res = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
            UnsafePointer<Int8>(passData!.bytes), passData!.length,
            UnsafePointer<UInt8>(data.bytes), data.length,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            1,
            UnsafeMutablePointer<UInt8>(result!.mutableBytes), result!.length)
        
        print("CCKeyDerivationPBKDF2:res = \(res):\(result?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))")
        
        self._passPhrase = NSString(string: "PassPhrasE")
        passData = self._passPhrase.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        data = NSMutableData(bytes: ptr.baseAddress, length: (_saltBin?.count)!)
        res = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
            UnsafePointer<Int8>(passData!.bytes), passData!.length,
            UnsafePointer<UInt8>(data.bytes), data.length,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            1,
            UnsafeMutablePointer<UInt8>(result!.mutableBytes), result!.length)
        
        print("CCKeyDerivationPBKDF3:res = \(res):\(result?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))")
        
    }
    
}
