//
//  ClientBridge.swift
//  GnsClientIOSTest
//
//  Created by David Westbrook on 11/5/14.
//  Copyright (c) 2014 University of Massachusetts Amherst (Computer Science). All rights reserved.
//

import Foundation
//import GNSClientKit

//enum AclAccessType {
//    case READ_WHITELIST
//    case WRITE_WHITELIST
//}

// ClientBridge handles the creation of the client, as well as the GuidEntry of the current
// account guid. It also does some error checking and makes the output prettier.
@objc public class ClientBridge : NSObject {
    
    @objc private var client: BasicTCPClient! // the client object itself - will be nill if we can't make a connection
    private var guidEntry: GuidEntry!   // the guid which keeps track of the alias, guid and keys for this account guid
    @objc private var verified: Bool = false; // Has the given account guid been verified yet. We could just look this up as well.
    
    @objc public class func newInstance(host: String, port:UInt16) -> ClientBridge {
        return ClientBridge(host: host, port: port)!;
    }

    /// Initializer for the non-Nat case
    ///
    @objc init?(host:String, port:UInt16) {
        super.init();
//        self.guidEntry = nil;
        self.client = BasicTCPClient(serverHost: host, serverPort: port)
        if self.client == nil {
            return nil
        }
    }
    
    /// Initializer for the case where we are behind a NAT
    ///
    @objc init?(host:String, port:UInt16, natPort:UInt16) {
//        self.client = BasicTCPClient(serverHost: host, serverPort: port, isNat: true, natPort: natPort)?
        super.init();
        self.client = BasicTCPClient(serverHost: host, serverPort: port)
        if self.client == nil {
            return nil
        }
    }
    
    // Creates a new account or looks up an existing one. Returns true if it was successful and
    // false if there was some problem or error.
    @objc public func lookupOrCreateAccount(alias: String, password: String, returnBlock:(resultString : String, error : String?) -> Void) {
        
        var accountGuid:String = ""
        var createKey:Bool = true // keep track of whether or not we need to create a new keypair
        
        // First the we do is check to see if a guid already exists for this alias.
        let (existingGuid, lookupError) = client.lookupGuid(alias)
//        let (existingGuid, lookupError) = client.lookupGuid("test@gnrs.name")
        
        // explicitly check for timeout here because if that is the error we're probably dead in the water
        if (lookupError == GNSProtocol.TIMEOUT) {
            return returnBlock(resultString: "",error: "timeout")
        }

        var resultString = ""; // something to return at the end
        // If the guid alreaday exists we use it
        if lookupError.isEmpty {
            resultString = "Found existing account with guid \(existingGuid)"
            accountGuid = existingGuid
            createKey = false
            // FIXME: gonna assume it has been verified here
            verified = true
        // otherwise we create a new guid
        } else {
            let (newAccountGuid, createError) = client!.accountGuidCreate(alias, password: password)
            // If there was problem creating the id let the user know
            if !createError.isEmpty {
                return returnBlock(resultString: "", error: "Problem creating account guid: \(createError)")
            // otherwise we're good to go
            } else {
                resultString = "Created guid \(newAccountGuid)"
                accountGuid = newAccountGuid
                verified = false
            }
        }
        
        // Initialize our guidEntry object
        guidEntry = GuidEntry(alias: alias, guid: accountGuid, createKeyPair: createKey)
        if (guidEntry == nil) {
            return returnBlock(resultString: "", error: "Private key not available on this device. ")
        } else {
            
            let (testGuid, lookupError) = client.lookupGuid("test@gnrs.name")
            
            client.aclAdd(AclAccessType.READ_WHITELIST,
                          targetGuid: guidEntry,
                          field: GNSProtocol.ENTIRE_RECORD,
                          accesserGuid: GNSProtocol.EVERYONE)

//            self.addAclToAllFields("READ_WHITELIST", accesserGuid: testGuid, completion: { (response, error) -> Void in
//
//                self.addAclToAllFields("WRITE_WHITELIST", accesserGuid: testGuid, completion: { (response, error) -> Void in
//                    return returnBlock(resultString: resultString, error: error)
//                })
//            })
            
//            return returnBlock(resultString: resultString, error: nil)
        }
    }
    
    // Sends the verification code to the server which will check it and return ok if we're good.
    @objc public func verifyAccount(code: String, completion:(result: Bool, error: String) -> Void) {
        if (guidEntry != nil) {
            let (verificationResult, verificationError) = client.accountGuidVerify(guidEntry, code: code)
            if verificationError.isEmpty {
                verified = true;
                return completion(result: true, error: "");
            } else {
                return completion(result: false, error: "Error verifying account: \(verificationError)");
            }
        } else {
            return completion(result: false, error: "Error: account not created")
        }
    }
  
    // Trys to read as single field from the GNS. Returns and empty string if there is a problem.
    @objc public func readField(field:String, completion:(result: String?, error: String?) -> Void) {
        if (guidEntry != nil) {
            let (result, error) = client.fieldRead(guidEntry.guid, field: field, reader: guidEntry)
            if (error.isEmpty) {
                return completion(result: result, error: nil)
            } else {
                return completion(result: nil, error: "Error reading field: \(error)")
            }
        } else {
            return completion(result: nil, error: "Error: account not created")
        }
    }
    
    // Trys to write a single field to the GNS. Returns true if we were successful.
    @objc public func writeField(field:String, value: AnyObject, completion:(success: Bool, error: String?) -> Void) {
        if (guidEntry != nil) {
            let (result, error) = client.fieldUpdate(guidEntry.guid, field: field, value: value, writer: guidEntry)
            if (error.isEmpty) {
                return completion(success: true, error: "")
            } else {
                return completion(success: false, error: "Error writing field: \(error)")
            }
        } else {
            return completion(success: false, error: "Error: account not created")
        }
    }
    
    // Reads all the fields for the guid and returns them as a JSON formatted string.
    @objc public func readAllFields(completion:(resultJson: String, error: String?) -> Void) {
        if (guidEntry != nil) {
            let (result, error) = client.read(guidEntry.guid, reader: guidEntry)
            if (error.isEmpty) {
                return completion(resultJson: result, error: nil)
            } else {
                return completion(resultJson: "", error: "Error writing field: \(error)")
            }
        } else {
            return completion(resultJson: "", error: "Error: account not created")
        }
    }
    
    // Updates the JSON object in the GNS associated with this guid. String should be formatted as a JSON Object. 
    // Returns true if we were successful.
    @objc public func updateFieldsFromJSON(value: String, completion: (result: Bool, error: String) -> Void) {
        let json = JSON(string: value, options: [], error: nil).naturalValue as! NSDictionary
        if (guidEntry != nil) {
            

            let (result, error) = client.update(guidEntry.guid, json: json, writer: guidEntry)
            if (error.isEmpty) {
                return completion(result: true, error: "")
            } else {
                return completion(result: false, error: "Error writing field: \(error)")
            }
        } else {
            return completion(result: false, error: "Error: account not created")
        }
    }
   
    @objc public func addAclToAllFields(accessType: String, accesserGuid: String, completion: (response: String, error: String) -> Void) {
        
        var aType = AclAccessType.READ_WHITELIST
        
        switch(accessType){
            case "READ_WHITELIST":
                aType = AclAccessType.READ_WHITELIST
                break;
        case "READ_BLACKLIST":
            aType = AclAccessType.READ_BLACKLIST
            break;
        case "WRITE_WHITELIST":
            aType = AclAccessType.WRITE_WHITELIST
            break;
        case "WRITE_BLACKLIST":
            aType = AclAccessType.WRITE_BLACKLIST
            break;
            default:
                aType = AclAccessType.READ_WHITELIST
            break;
        }
        
        // CRASHS ALOT
        if(guidEntry != nil){
//            print("AType: %@", aType);
//            print("GuidEntry: %@", guidEntry);
//            print("accesserGuid: %@", accesserGuid);
            let aclReturn = self.client.aclAdd(aType, targetGuid: guidEntry, field: GNSProtocol.ALL_FIELDS, accesserGuid: accesserGuid)
            return completion(response: aclReturn.0, error: aclReturn.1);
        }
        
        return completion(response: "", error: "");
    }
    
    // Returns the public key as a base64 encoded string.
    @objc public func publicKeyString() -> String {
        if (guidEntry != nil) {
            return guidEntry.keyPair.getRSAPublicKeyEncoded().base64EncodedStringWithOptions([])
        } else {
            return ("")
        }
    }
    
    // Returns the guid as a string. The standard guid format is a hex encoded string.
    @objc public func guidString() -> String {
        if (guidEntry != nil) {
            return guidEntry.guid
        } else {
            return ("")
        }
    }
    
    @objc public func disconnect() {
        if let client = client {
            client.stop()
            guidEntry = nil
            verified = false
        }
    }
    
    // Returns true if the we have registered an account guid.
    @objc public func isRegistered() -> Bool {
        return guidEntry != nil
    }
    
    // Returns true if the we have registered an account guid.
    @objc public func isVerified() -> Bool {
        return verified
    }
    
}

// MARK: - Printable
extension ClientBridge {
    override public var description: String {
        if let client = client {
            return "Connected to \(client.serverHost):\(client.serverPort)"
//            if (!client.isNat) {
//                return "Connected to \(client.serverHost):\(client.serverPort)"
//            } else {
//                return "Connected to \(client.serverHost):\(client.serverPort) listening on \(client.listenPort)"
//            }
        } else {
            return "Client not connected."
        }
    }
}


