//
//  MessageExtractor.swift
//  GnsClientIOS
//
//  Created by David Westbrook on 10/20/14.
//  Copyright (c) 2014 University of Massachusetts.
//

import Foundation

/// Because swift doesn't currently support 
/// class let HEADER_PATTERN: String = "&";
struct Constants {
    static let HEADER_SIZE = 8;
    static let PREAMBLE:Int32 = 723432553
    static let debuggingEnabled:Bool = false;
   
}

class MessageExtractor {
    
    // Note that this encodes the data into NIO_CHARSET_ENCODING before returning it.
    class func prependHeader(command: NSData) -> NSData {
        // Make a string using the detault encoding which the JSON decoder uses
        if let commandString: NSString = Utils.NSDataToString(command) {
            if Constants.debuggingEnabled{print("Send command: \(commandString)")}
            // Convert the command to the encoding that NIO wants
            let commandData = Utils.StringToNSData(commandString as String, encoding: GNSProtocol.NIO_CHARSET_ENCODING);
            // Wrote out some 4 bit integers for the preamble
            let length:Int32 = Int32(commandData.length);
            var preamble = Constants.PREAMBLE.bigEndian;
            var dataLength = length.bigEndian;
            if Constants.debuggingEnabled{print("Send data length: \(commandData.length)")}
            // Make a mutable data
            let result = NSMutableData();
            // Append the length
            result.appendBytes(&preamble, length: sizeofValue(preamble));
            result.appendBytes(&dataLength, length: sizeofValue(dataLength));
            if Constants.debuggingEnabled{
                print("\(sizeofValue(preamble)) \(sizeofValue(dataLength))")}
            // Append the actual command data
            result.appendData(commandData);
            // Return the whole thing as non mutable data
            return NSData(data: result);
        } else {
            if Constants.debuggingEnabled{print("Null command")}
           return NSData();
        }
       
        //return Utils.StringToNSData(Constants.HEADER_PATTERN + "\(countElements(commandString))" + Constants.HEADER_PATTERN + commandString, encoding: GNSProtocol.NIO_CHARSET_ENCODING)
    }
    
    class func getPayloadLength(data:NSData, start:Int) ->(Int) {
        var preamble: Int = 0
        var length:  Int = 0
        if Constants.debuggingEnabled{
            let preambleData:NSData = data.subdataWithRange(NSMakeRange(start, 4));
            let lengthData:NSData = data.subdataWithRange(NSMakeRange(start + 4, 4));
            print(" \(preambleData)");
            print(" \(lengthData)");
        }
        
        preamble = getBigIntFromData(data, offset: start);
        length = getBigIntFromData(data, offset: start + 4);
        //data.getBytes(&preamble, range: NSMakeRange(start, 4));
        //data.getBytes(&length, range: NSMakeRange(start + 4, 4));
        if Constants.debuggingEnabled{
            print(preamble);
            print(length);
        }
        return length;
    }
    
    class func getBigIntFromData(data: NSData, offset: Int) -> Int {
        let rng = NSRange(location: offset, length: 4)
        var i = [UInt32](count: 1, repeatedValue:0)
        
        data.getBytes(&i, range: rng)
        return Int(i[0].bigEndian)// return Int(i[0]) for littleEndian
    }
    
    /// This method does much of the work to try to extract a single message. Its
    /// purpose is to parse the first correctly header-formatted message and return
    /// it. The second return value is any leftover portion of str.
    ///
    /// It works as follows. First, it checks if the string length is at least
    /// twice the length of the special pattern in the header. If so, it attempts
    /// to find the first two occurrences of the pattern. If so, it attempts to
    /// parse a size in between those two patterns. If it successfully parses
    /// a size, it checks if the string has at least size bytes beyond the second
    /// occurrence of the special pattern. If so, it has found a correctly header-
    /// formatted message.
    ///
    /// If the size is not correctly formatted, it gets treated as a 0 size,
    /// so the header will be removed. As a consequence, all bytes up to the
    /// next correctly formatted message will be discarded.
    ///
    class func extractMessage(inputString:NSData) ->(String, NSData) {
        let inputStringLength = inputString.length;
        // this holds the end of the inputString we don't parse when we finish, if any
        var leftOver = inputString
        // this is where we put the message that we actually extract
        var extractedMessage = NSData();
        // if the input string can't actually the preamble and length we punt
        if inputStringLength > Constants.HEADER_SIZE {
            var preamble = Constants.PREAMBLE.bigEndian;
            if Constants.debuggingEnabled{print("Preamble size \(sizeofValue(preamble))")}
            let pattern = NSData(bytes: &preamble, length: sizeofValue(preamble))
            let preambleRange = inputString.rangeOfData(pattern, options: [], range:NSMakeRange(0, inputStringLength));
            if Constants.debuggingEnabled{print("Preamble range: location: \(preambleRange.location) length: \(preambleRange.length)")}
            //If the pattern was found, get the next byte
            if (preambleRange.location != NSNotFound) {
                let lengthStart = preambleRange.location;
                let payloadLength = getPayloadLength(inputString, start: lengthStart);
                if Constants.debuggingEnabled{print("Payload length \(payloadLength)")}
                let messageStart = lengthStart + Constants.HEADER_SIZE;
                // check to make sure the size we parsed doesn't go off the end of the string
                if (messageStart + payloadLength <= inputStringLength) {
                    extractedMessage = inputString.subdataWithRange(NSMakeRange(messageStart, payloadLength));
                    leftOver = inputString.subdataWithRange(NSMakeRange(messageStart + payloadLength,
                        inputStringLength - (payloadLength + Constants.HEADER_SIZE)))
                } else {
                    // the size we parsed goes off the end of the string
                    if Constants.debuggingEnabled{print("Size goes off end of string")}
                }
            } else {
                // didn't find the preamble byte
                if Constants.debuggingEnabled{print(inputString, terminator: "")}
            }
        } else {
            // input string is shorter than header size
            if Constants.debuggingEnabled{print(leftOver, terminator: "")}
        }
          let message = Utils.NSDataToString(extractedMessage, encoding: GNSProtocol.NIO_CHARSET_ENCODING);
          return (message! as String, leftOver)
    }

//    class func extractMessage(inputString:String) ->(String, String) {
//        let inputStringLength = countElements(inputString)
//        // this holds the end of the inputString we don't parse when we finish, if any
//        var leftOver = inputString
//        // this is where we put the message that we actually extract
//        var extractedMessage = ""
//        // if the input string can't actually hold two copies of the pattern string we punt right now
//        if inputStringLength > 2 * countElements(Constants.HEADER_PATTERN) {
//            // otherwise look for the first occurance of the pattern
//            if let firstRange = inputString.rangeOfString(Constants.HEADER_PATTERN) {
//                //println(firstRange)
//                var firstStart = firstRange.endIndex
//                let afterFirstRange = firstStart..<inputString.endIndex
//                // look for the second occurance of the pattern
//                if let secondRange = inputString.rangeOfString(Constants.HEADER_PATTERN, options: nil, range: afterFirstRange) {
//                    let lengthRange = firstRange.endIndex..<secondRange.startIndex
//                    let rangeString = inputString.substringWithRange(lengthRange)
//                    // size defaults to zero if header isn't formatted correctly
//                    var size:Int = 0
//                    // parse the size
//                    if let okSize = rangeString.toInt() {
//                        size = okSize
//                    }
//                    // check to make sure the size we parsed doesn't go off the end of the string
//                    if (distance(secondRange.endIndex, inputString.endIndex) >= size) {
//                        let messageEnd = advance(secondRange.endIndex, size)
//                        let messageRange = secondRange.endIndex..<messageEnd
//                        extractedMessage = inputString.substringWithRange(messageRange)
//                        let leftOverRange = messageEnd..<inputString.endIndex
//                        leftOver = inputString.substringWithRange(leftOverRange)
//                    } else {
//                        // the size we parsed goes off the end of the string
//                        if Constants.debuggingEnabled{println("Size goes off end of string")}
//                    }
//                } else {
//                    // didn't find the second occurance of the pattern
//                    if Constants.debuggingEnabled {println("Only one \(Constants.HEADER_PATTERN) found")}
//                }
//                
//            } else {
//                // didn't find a single occurance of the header string
//                if Constants.debuggingEnabled{print(inputString)}
//            }
//        } else {
//            // input string is shorter than two of the pattern string
//            if Constants.debuggingEnabled{print(leftOver)}
//        }
//        return (extractedMessage, leftOver)
//    }

    
    
    /// Invokes extractMessage while it can keep extracting more messages.
    /// Returns an array of extracted strings.
    ///
    class func extractMultipleMessages(inputString:NSData) ->(Array<String>, String) {
        var inputString = inputString
    //class func extractMultipleMessages(var inputString:String) ->(Array<String>, String) {
        var result: [String] = []
        if Constants.debuggingEnabled{print("Input length: \(inputString.length)")}
        while inputString.length > 0 {
        //while countElements(inputString) > 0 {
            let (extractedMessage, leftOver) = extractMessage(inputString)
            //let (extractedMessage, leftOver) = extractMessage(inputString)
            result.append(extractedMessage)
            // if we can't extract anything we punt
            if leftOver.isEqualToData(inputString) {
                break
            } else {
                // try again with what was left
                inputString = leftOver
            }
        }
        if Constants.debuggingEnabled{print("Result: \(result)")}
        // return what we couldn't parse as the second argument
        return (result, Utils.NSDataToString(inputString, encoding: GNSProtocol.NIO_CHARSET_ENCODING)! as String);
    }
    
}
