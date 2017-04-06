//
//  GuidEntry.swift
//  GnsClientIOS
//
//  Created by David Westbrook on 10/22/14.
//  Copyright (c) 2014 University of Massachusetts.
//

import Foundation

// GuidEntry bundles together the information need to create and sign a command.
// It also handles reading the KeyPair from the keychain.

// This class really ends up being a wrapper around the Keypair class which 
// does all the heavy lifting. In fact the only thing in here that isn't in
// keypair is the alias. Do we need both? Maybe?

public struct GuidEntry {
    public var alias: String;
    public var guid: String
    public var keyPair: KeyPair
}

extension GuidEntry {
    
    /// This initializer automagically handles reading the keyPair from the keychain.
    /// The createKeyPair parameter is a boolean that indicates whether to lookup or create a new keypair. 
    /// If it is false and the key pair does not already exist in the keychain you will get an error.
    ///
    public init?(alias: String, guid:String, createKeyPair:Bool) {
        let keyPair = KeyPair(guid: guid) // doesn't actually create the key in the keychain, it is done lazily
        // Check to make sure the key already exists if createKeyPair is false.
        if createKeyPair || keyPair.publicKeyInKeyChain(guid) {
            self.init(alias: alias, guid: guid, keyPair: keyPair)
        } else {
            return nil
        }
    }
}
