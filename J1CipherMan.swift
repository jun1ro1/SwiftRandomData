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
    var      _cek              = NSMutableData(length: 32)
    var      _iv               = NSMutableData(length: 32)

    
    
    let saltLength = 16;
    
    var randgen = J1RandomData()

    init() {
        self._saltBin = self.randgen.getRandomData(saltLength)
        guard self._saltBin != nil else {
            return
        }
        
        // http://www.iteachcoding.com/how-to-hmac-sha1-sign-an-api-request-using-swift
        // http://spin.atomicobject.com/2015/02/23/c-libraries-swift/
        
        var ptr = UnsafeBufferPointer(start: _saltBin!, count: (_saltBin?.count)!)
        self._saltStr = NSData(bytes: ptr.baseAddress, length: (_saltBin?.count)!)
            .base64EncodedStringWithOptions(.Encoding64CharacterLineLength)

        let data = NSMutableData(bytes: ptr.baseAddress, length: (_saltBin?.count)!)
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))
        let passData = self._passPhrase.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
       
        guard CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
            UnsafePointer<Int8>(passData!.bytes), passData!.length,
            UnsafePointer<UInt8>(data.bytes), data.length,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            1,
            UnsafeMutablePointer<UInt8>(result!.mutableBytes), result!.length) == 0
            else {
                return
        }
        self._kek = NSMutableData(data: result!)
        
        print("CCKeyDerivationPBKDF = \(self._kek!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))")
        
        let cek = self.randgen.getRandomData(32)
        ptr = UnsafeBufferPointer(start: cek!, count: cek!.count)
        self._cek = NSMutableData(bytes: ptr.baseAddress, length: ptr.count)
        
        let contents = "The quick brown fox jumps over the lazy white dog. 0123456789"
        
        let iv = self.randgen.getRandomData(32)
        ptr = UnsafeBufferPointer(start: iv!, count: iv!.count)
        self._iv = NSMutableData(bytes: ptr.baseAddress, length: ptr.count)

        let plain = NSMutableData(data: contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        let cipher = NSMutableData(length: contents.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)+kCCBlockSizeAES128);
        var dataMoved: size_t = 0
        
        var stat: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        stat = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding),
            UnsafePointer<Int8>(self._cek!.bytes), self._cek!.length,
            nil,
            UnsafePointer(plain.bytes), plain.length,
            UnsafeMutablePointer(cipher!.bytes), cipher!.length,
            &dataMoved
        )
        if stat == CCCryptorStatus(kCCSuccess) {
            cipher!.length = dataMoved
        }
        
        print("dataMoved=\(dataMoved)")
        print("Encrypt stat=\(stat)")
        print("CCCypt Encrypt = \(cipher!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))")
        
        stat = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES128),
            CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode),
            UnsafePointer<Int8>(self._cek!.bytes), self._cek!.length,
            nil,
            UnsafePointer(cipher!.bytes), cipher!.length,
            UnsafeMutablePointer(plain.bytes), plain.length,
            &dataMoved
        )
        if stat == 0 {
            plain.length = dataMoved
        }
        print("dataMoved=\(dataMoved)")
        print("Decrypt stat=\(stat)")
        print("CCCypt Decrypt = \(plain)")
        let plainStr = NSString(data: plain, encoding: NSUTF8StringEncoding)
        print("CCCrypt Decrpt Sltring = \(plainStr!)")
    }
    
}

/*!
@function   CCCrypt
@abstract   Stateless, one-shot encrypt or decrypt operation.
This basically performs a sequence of CCCrytorCreate(),
CCCryptorUpdate(), CCCryptorFinal(), and CCCryptorRelease().

@param      alg             Defines the encryption algorithm.


@param      op              Defines the basic operation: kCCEncrypt or
kCCDecrypt.

@param      options         A word of flags defining options. See discussion
for the CCOptions type.

@param      key             Raw key material, length keyLength bytes.

@param      keyLength       Length of key material. Must be appropriate
for the select algorithm. Some algorithms may
provide for varying key lengths.

@param      iv              Initialization vector, optional. Used for
Cipher Block Chaining (CBC) mode. If present,
must be the same length as the selected
algorithm's block size. If CBC mode is
selected (by the absence of any mode bits in
the options flags) and no IV is present, a
NULL (all zeroes) IV will be used. This is
ignored if ECB mode is used or if a stream
cipher algorithm is selected.

@param      dataIn          Data to encrypt or decrypt, length dataInLength
bytes.

@param      dataInLength    Length of data to encrypt or decrypt.

@param      dataOut         Result is written here. Allocated by caller.
Encryption and decryption can be performed
"in-place", with the same buffer used for
input and output.

@param      dataOutAvailable The size of the dataOut buffer in bytes.

@param      dataOutMoved    On successful return, the number of bytes
written to dataOut. If kCCBufferTooSmall is
returned as a result of insufficient buffer
space being provided, the required buffer space
is returned here.

@result     kCCBufferTooSmall indicates insufficent space in the dataOut
            buffer. In this case, the *dataOutMoved
            parameter will indicate the size of the buffer
            needed to complete the operation. The
            operation can be retried with minimal runtime
            penalty.
kCCAlignmentError indicates that dataInLength was not properly
aligned. This can only be returned for block
ciphers, and then only when decrypting or when
encrypting with block with padding disabled.
kCCDecodeError  Indicates improperly formatted ciphertext or
a "wrong key" error; occurs only during decrypt
operations.
*/

/*
CCCryptorStatus CCCrypt(
    CCOperation op,         /* kCCEncrypt, etc. */
    CCAlgorithm alg,        /* kCCAlgorithmAES128, etc. */
    CCOptions options,      /* kCCOptionPKCS7Padding, etc. */
    const void *key,
    size_t keyLength,
    const void *iv,         /* optional initialization vector */
    const void *dataIn,     /* optional per op and alg */
    size_t dataInLength,
    void *dataOut,          /* data RETURNED here */
    size_t dataOutAvailable,
    size_t *dataOutMoved)
*/

