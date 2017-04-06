//
//  Utils.swift
//  ConnectTest
//
//  Created by David Westbrook on 10/15/14.
//  Copyright (c) 2014 University of Massachusetts. All rights reserved.
//
//

import Foundation

private struct Globals {
    static let CHARACTERS = Utils.arrayOfAThroughZ() + Utils.arrayOfZeroThroughNine()
    
}

// NSISOLatin1StringEncoding

public class Utils {
    
    public class func NSDataToString(data : NSData) -> String? {
        return NSDataToString(data, encoding: NSUTF8StringEncoding)
        //return NSString(data: data, encoding: NSUTF8StringEncoding)
    }
    
    public class func StringToNSData(string: String) -> NSData {
        return StringToNSData(string, encoding: NSUTF8StringEncoding)
        //return (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    public class func NSDataToString(data : NSData, encoding: UInt) -> String? {
        return (NSString(data: data, encoding: encoding) as! String)
    }
    
    public class func StringToNSData(string: String, encoding: UInt) -> NSData {
        return (string as NSString).dataUsingEncoding(encoding)!
    }
    
    func sha256(securityString : String) -> String {
        let data = securityString.dataUsingEncoding(NSUTF8StringEncoding)!
        var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in hash {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
    
    public class func delayInSeconds(delay: Double) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    }
    
    public class func randomString(len:Int) -> String {
        var result:String = ""
        for _ in 1...len {
            result = result + Globals.CHARACTERS.randomItem()
        }
        return result
    }
   
    private class func arrayOfAThroughZ() -> [String] {
        return Array(0x61...0x7A).map {String(UnicodeScalar($0))}
    }
    
    private class func arrayOfZeroThroughNine() -> [String] {
        return Array(0...9).map{String($0) }
    }
    
}

extension Array {
    func randomItem() -> Element {
        let random = Int( arc4random()) % self.count
        return self[random]
    }
}