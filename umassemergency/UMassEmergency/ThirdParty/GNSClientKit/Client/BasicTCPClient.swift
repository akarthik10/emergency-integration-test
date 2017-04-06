//
//  BasicTCPClient.swift
//
//  Created by David Westbrook on 10/8/14.
//  Copyright (c) 2014 University of Massachusetts.
//

import Foundation

///
/// This class defines a basic client to communicate with a GNS instance over TCP. This
/// class contains a concise set of read and write commands which read and write JSON Objects.
/// It also contains the basic field read and write commands as well a
/// set of commands to use context aware group guids.
///
/// @author <a href="mailto:westy@cs.umass.edu">Westy</a>
///
public class BasicTCPClient: NSObject {
    // Socket for outgoing connections
    private var asyncSocket: GCDAsyncSocket?
    // If this is true (the new default as of 12/14) it means that we're connnection to
    // a server that supports duplex NIO
    //private var duplexNIO: Bool = true;
    // Socket for incoming connections
    private var acceptSocket: GCDAsyncSocket?
    // Used by the didAcceptNewSocket callback to insure that incoming connections aren't deallocated
    private var readSocket: GCDAsyncSocket?
    
    // Hostname of the server we are connecting to
    public var serverHost: String = "127.0.0.1" // Initial value is unnecessary - overwritten by the init method
    // Port on the server we are connecting to
    public var serverPort: UInt16 = 24398       // Initial value is unnecessary - overwritten by the init method
    // Port that we listen for incoming connections on
    public let listenPort: UInt16 = 0
    // timeout in seconds when waiting for responses from the server
    public var readTimeout: Double = 20.0;
    // timeout in seconds when waiting for the initial remote connection to open
    public var openTimeout: Double = 20.0;
    
    // Used by GCDAsync for scheduling send and receive tasks
    private let outgoingQueue:dispatch_queue_t = dispatch_queue_create("cs.umass.edu.gnsClient.outgoingQueue", nil);
    private let incomingQueue:dispatch_queue_t = dispatch_queue_create("cs.umass.edu.gnsClient.incomingQueue", nil);
    
    // These two are used to facilitate synchronus use of the GCD sockets
    private let connectSemaphore:dispatch_semaphore_t = dispatch_semaphore_create(0);
    private let readSemaphore:dispatch_semaphore_t = dispatch_semaphore_create(0);
    
    private let debuggingEnabled:Bool = false;
    
    // MARK: Initialization
    
    /// Initializes a new BasicTCPClient object.
    ///
    public init?(serverHost: String, serverPort: UInt16) {
        super.init()
        self.serverHost = serverHost
        self.serverPort = serverPort
        if !openAndListen() { return nil}
    }
    
    /// Immediately disconnects both the outgoing and incoming sockets.
    ///
    public func stop() {
        if let asyncSocket = self.asyncSocket {
            asyncSocket.disconnect()
        }
        if let acceptSocket = self.acceptSocket {
            acceptSocket.disconnect()
        }
    
    }
    
    // MARK: Client Commands

    // MARK: Client Data Commands
    
    /// Updates the JSONObject associated with targetGuid using the given JSONObject.
    /// Fields not specified in the given JSONObject are not modified. If you want
    /// to delete a field in a guid see the fieldRemove method.
    /// The writer is the guid of the user attempting access. Signs the query using
    /// the private key of the user associated with the writer guid.
    ///
    public func update (targetGuid: String, json: NSDictionary, writer: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.ReplaceUserJSON,
            keyPair: writer.keyPair,
            //action: CommandType.ReplaceUserJSON.name, //  GNSProtocol.REPLACE_USER_JSON,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.WRITER, writer.guid,
            GNSProtocol.USER_JSON, json)
        return processResponse(sendCommand(command))
    }
    
    /// Updates the field in the targetGuid. The writer is the guid
    /// of the user attempting access. Signs the query using
    /// the private key of the writer guid.
    ///
    public func fieldUpdate (targetGuid: String, field: String, value: AnyObject, writer: GuidEntry) -> (response: String, error: String) {
        let jsonToSend: NSMutableDictionary = NSMutableDictionary()
        jsonToSend.setObject(value, forKey: field)
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.ReplaceUserJSON,
                             keyPair: writer.keyPair,
            //action: CommandType.ReplaceUserJSON.name, // GNSProtocol.REPLACE_USER_JSON,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.WRITER, writer.guid,
            GNSProtocol.USER_JSON, jsonToSend)
        return processResponse(sendCommand(command))
    }
    
    /// Reads the JSONObject for the given targetGuid.
    /// The reader is the guid of the user attempting access. Signs the query using
    /// the private key of the user associated with the reader guid
    ///
    public func read (targetGuid: String, reader: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.ReadArray,
                             keyPair: reader.keyPair,
            // uses the old style read... for now
            //action: CommandType.ReadArray.name, // GNSProtocol.READ_ARRAY,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, GNSProtocol.ENTIRE_RECORD,
            GNSProtocol.READER, reader.guid)
        return processResponse(sendCommand(command))
    }
    
    
    /// Reads the JSONObject for the given targetGuid. Unsigned which
    /// means all fields need to have all users access for this to succeed.
    ///
    public func read (targetGuid: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        // uses the old style read... for now
        createCommand(CommandType.ReadArrayUnsigned,
            //CommandType.ReadArrayUnsigned.name, /// GNSProtocol.READ_ARRAY_UNSIGNED,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, GNSProtocol.ENTIRE_RECORD)
        return processResponse(sendCommand(command))
    }
    
    ///
    /// Reads the value of field for the given targetGuid.
    /// Field is a string the naming the field. Field can use dot
    /// notation to indicate subfields. The reader is the guid of the
    /// user attempting access. This method signs the query using the
    /// private key of the user associated with the reader guid.
    ///
    public func fieldRead (targetGuid: String, field: String, reader: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.Read,
                             keyPair: reader.keyPair,
            //action: CommandType.Read.name, //GNSProtocol.READ,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, field,
            GNSProtocol.READER, reader.guid)
        return processResponse(sendCommand(command))
    }
    
    /// Reads the value of field for the given targetGuid.
    /// Field is a string the naming the field. Field can use dot
    /// notation to indicate subfields. Unsigned which
    /// means this field should be all users accessible for this to succeed.
    ///
    public func fieldRead (targetGuid: String, field: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.ReadUnsigned,
                      //CommandType.ReadUnsigned.name, //GNSProtocol.READ_UNSIGNED,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, field)
        return processResponse(sendCommand(command))
    }
    
    /// Removes a field in the JSONObject record of the given targetGuid.
    /// The writer is the guid of the user attempting access.
    /// Signs the query using the private key of the user
    /// associated with the writer guid.
    ///
    public func fieldRemove (targetGuid: String, field: String, writer: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RemoveField,
                             keyPair: writer.keyPair,
            //action: CommandType.RemoveField.name, //GNSProtocol.REMOVE_FIELD,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, field,
            GNSProtocol.WRITER, writer.guid)
        return processResponse(sendCommand(command))
    }
    
    // MARK: Client Select Commands
    
    /// Selects all records that match query.
    /// Returns the result of the query as a JSONArray of guids.
    ///
    /// The query syntax is described here:
    /// https://gns.name/wiki/index.php?title=Query_Syntax
    ///
    /// Currently there are two predefined field names in the GNS client (this is in edu.umass.cs.gns.client.GnsProtocol):
    /// LOCATION_FIELD_NAME = "geoLocation"; Defined as a "2d" index in the database.
    /// IPADDRESS_FIELD_NAME = "netAddress";
    ///
    /// There are links in the wiki page above to find the exact syntax for querying spacial coordinates.
    ///
    public func selectQuery (query: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.SelectQuery,
            //CommandType.SelectQuery.name, //GNSProtocol.SELECT_QUERY,
            keysAndValues:
            GNSProtocol.QUERY, query)
        return processResponse(sendCommand(command))
    }
    
    /// Set up a context aware group guid using a query.
    /// Also returns the result of the query as a JSONArray of guids.
    ///
    /// The query syntax is described here:
    /// https://gns.name/wiki/index.php?title=Query_Syntax
    ///
    /// interval is the refresh interval in seconds - default is 60 - (lookup queries that happen quicker than
    /// this will get cached results)
    ///
    public func selectSetupGroupQuery (guid: String, query: String, interval:Int) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.SelectGroupSetupQuery,
                      //CommandType.SelectGroupSetupQuery.name, // GNSProtocol.SELECT_GROUP_SETUP_QUERY,
            keysAndValues:
            GNSProtocol.GUID, guid,
            GNSProtocol.QUERY, query,
            GNSProtocol.INTERVAL, interval
        )
        return processResponse(sendCommand(command))
    }
    
    /// Look up the value of a context aware group guid using a query.
    /// Returns the result of the query as a JSONArray of guids. The results will be
    /// stale if the queries that happen more quickly than the refresh interval given during setup.
    ///
    public func selectLookupGroupQuery (guid: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.SelectGroupLookupQuery,
                      //CommandType.SelectGroupLookupQuery.name, //GNSProtocol.SELECT_GROUP_LOOKUP_QUERY,
            keysAndValues:
            GNSProtocol.GUID, guid
        )
        return processResponse(sendCommand(command))
    }
    
    // MARK: Client Account Commands
    
    /// Obtains the guid of the alias from the GNS server.
    ///
    public func lookupGuid(alias: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.LookupGuid,
                      //CommandType.LookupGuid.name, //GNSProtocol.LOOKUP_GUID,
            keysAndValues: GNSProtocol.NAME, alias)
        return processResponse(sendCommand(command))
    }
    
    /// If this is a sub guid returns the account guid it was created under.
    ///
    public func lookupPrimaryGuid(guid: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.LookupPrimaryGuid,
                      //CommandType.LookupPrimaryGuid.name, //GNSProtocol.LOOKUP_PRIMARY_GUID,
            keysAndValues: GNSProtocol.GUID, guid)
        return processResponse(sendCommand(command))
    }
    
    /// Returns a JSON object containing all of the guid meta information.
    /// This method returns meta data about the guid.
    /// If you want any particular field or fields of the guid
    /// you'll need to use one of the read methods.
    ///
    public func lookupGuidRecord(guid: String) -> (response: JSON, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.LookupGuidRecord,
                      //CommandType.LookupGuidRecord.name, //GNSProtocol.LOOKUP_GUID_RECORD,
            keysAndValues: GNSProtocol.GUID, guid)
        return processResponseJSONObject(sendCommand(command))
    }
    
    /// Returns a JSON object containing all of the account meta information for an
    /// account guid.
    /// This method returns meta data about the account associated with this guid
    /// if and only if the guid is an account guid.
    /// If you want any particular field or fields of the guid
    /// you'll need to use one of the read methods.
    ///
    public func lookupAccountRecord(guid: String) -> (response: JSON, error: String) {
        let command: NSMutableDictionary =
        createCommand(CommandType.LookupAccountRecord,
                      //CommandType.LookupAccountRecord.name, //GNSProtocol.LOOKUP_ACCOUNT_RECORD,
            keysAndValues: GNSProtocol.GUID, guid)
        return processResponseJSONObject(sendCommand(command))
    }
    
    /// Get the public key for a given alias.
    ///
    public func publicKeyLookupFromAlias(alias: String) -> (response: String, error: String) {
        let (guid, error) = lookupGuid(alias)
        if error.isEmpty {
            return publicKeyLookupFromGuid(guid)
        } else {
            return ("", error)
        }
    }
    
    /// Get the public key for a given GUID.
    ///
    public func publicKeyLookupFromGuid(guid: String) -> (response: String, error: String) {
        let (guidRecord, lookupError)  = lookupGuidRecord(guid)
        if (lookupError.isEmpty) {
            // do more here like maybe stuffing it in the keychain and returning a reference?
            return (guidRecord[GNSProtocol.GUID_RECORD_PUBLICKEY].stringValue!, "")
        } else {
            return ("", lookupError)
        }
    }
    
    /// Register a new account guid with the corresponding alias on the GNS server.
    /// This generates a new guid and a public / private key pair. Returns a
    /// GuidEntry for the new account which contains all of this information.
    ///
    /// alias is a human readable alias to the guid - usually an email
    ///
    public func accountGuidCreate(alias: String, password: String) -> (response: String, error: String) {
        //let size:UInt32 = 1024;
        let keyPair: KeyPair = KeyPair()
        let guid = keyPair.sha1PublicKeyToString()
        if debuggingEnabled {print("#####Guid: " + guid)}
        let publicKeyString: String = keyPair.getRSAPublicKeyEncoded().base64EncodedStringWithOptions([])
        if debuggingEnabled {print("#####Public Key: " + publicKeyString)}
        let command: NSMutableDictionary = createAndSignCommand(CommandType.RegisterAccount,
                                                                keyPair: keyPair,
            //action: CommandType.RegisterAccount.name, //GNSProtocol.REGISTER_ACCOUNT,
            keysAndValues:
            GNSProtocol.NAME, alias,
            GNSProtocol.PUBLIC_KEY, publicKeyString,
            GNSProtocol.PASSWORD, Utils.StringToNSData(password).base64EncodedStringWithOptions([]))
        let (returnedGuid, error) = processResponse(sendCommand(command))
        if error.isEmpty {
            if returnedGuid == guid {
                return (guid, "")
            } else {
                return ("", "returned guid mismatch: \(guid) \(returnedGuid)")
            }
        } else {
            return ("", error)
        }
    }
    
    /// Verify an account by sending the verification code back to the server.
    ///
    public func accountGuidVerify (guidEntry: GuidEntry, code: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.VerifyAccount,
                             keyPair: guidEntry.keyPair,
            //action: CommandType.VerifyAccount.name, //GNSProtocol.VERIFY_ACCOUNT,
            keysAndValues:
            GNSProtocol.GUID, guidEntry.guid,
            GNSProtocol.CODE, code)
        return processResponse(sendCommand(command))
    }
    
    // FIXME: Need a method for checking the verifiction status of an account.
    
    
    /// Deletes the account given by name
    ///
    public func accountGuidRemove (guidEntry: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RemoveAccount,
                             keyPair: guidEntry.keyPair,
            //action: CommandType.RemoveAccount.name, //GNSProtocol.REMOVE_ACCOUNT,
            keysAndValues:
            GNSProtocol.GUID, guidEntry.guid)
        return processResponse(sendCommand(command))
    }
    
    //FIXME: Add code to remove the keypair from the key chain
    
    /// Creates an new GUID associated with an account on the GNS server.
    ///
    public func guidCreate(accountGuidEntry: GuidEntry, alias: String) -> (response: String, error: String) {
        let keyPair: KeyPair = KeyPair()
        let guid = keyPair.sha1PublicKeyToString()
        if debuggingEnabled {print("#####Guid: " + guid)}
        let publicKeyString: String = keyPair.getRSAPublicKeyEncoded().base64EncodedStringWithOptions([])
        if debuggingEnabled {print("#####Public Key: " + publicKeyString)}
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.AddGuid,
                             keyPair: accountGuidEntry.keyPair,
            //action:  CommandType.AddGuid.name, //GNSProtocol.ADD_GUID,
            keysAndValues:
            GNSProtocol.GUID, accountGuidEntry.guid,
            GNSProtocol.NAME, alias,
            GNSProtocol.PUBLIC_KEY, publicKeyString)
        let (returnedGuid, error) = processResponse(sendCommand(command))
        if error.isEmpty {
            if returnedGuid == guid {
                return (guid, "")
            } else {
                return ("", "returned guid mismatch: \(guid) \(returnedGuid)")
            }
        } else {
            return ("", error)
        }
    }
    
    /// Removes a guid (not for account Guids - use removeAccountGuid for them).
    ///
    public func guidRemove (guidEntry: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RemoveGuidNoAccount,
                             keyPair: guidEntry.keyPair,
            //action:  CommandType.RemoveGuidNoAccount.name, //GNSProtocol.REMOVE_GUID_NO_ACCOUNT,
            keysAndValues:
            GNSProtocol.GUID, guidEntry.guid)
        return processResponse(sendCommand(command))
    }
    
    /// Removes a guid given the guid and the associated account guid.
    ///
    public func guidRemove (accountGuidEntry: GuidEntry, guid: String)-> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RemoveGuid,
                             keyPair: accountGuidEntry.keyPair,
            //action: CommandType.RemoveGuid.name, //GNSProtocol.REMOVE_GUID,
            keysAndValues:
            GNSProtocol.GUID, guid,
            GNSProtocol.ACCOUNT_GUID, accountGuidEntry.guid)
        return processResponse(sendCommand(command))
    }
    
    // MARK: Client Group Commands
    
    /// Return the list of guids that are members of the group. Signs the query
    /// using the private key of the user associated with the guid.
    ///
    public func groupGetMembers(groupGuid: String, reader: GuidEntry) -> (response: JSON, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.GetGroupMembers,
                             keyPair: reader.keyPair,
            //action: CommandType.GetGroupMembers.name, //GNSProtocol.GET_GROUP_MEMBERS,
            keysAndValues:
            GNSProtocol.GUID, groupGuid,
           GNSProtocol.READER, reader.guid)
        return processResponseJSONArray(sendCommand(command))
    }
    
    /// Return a list of the groups that the guid is a member of. Signs the query
    /// using the private key of the user associated with the guid.
    ///
    public func guidGetGroups(guid: String, reader: GuidEntry) -> (response: JSON, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.GetGroups,
                             keyPair: reader.keyPair,
            //action: CommandType.GetGroups.name, //GNSProtocol.GET_GROUPS,
            keysAndValues:
            GNSProtocol.GUID, guid,
            GNSProtocol.READER, reader.guid
        )
        return processResponseJSONArray(sendCommand(command))
    }
    
    /// Add a guid to a group guid. Any guid can be a group guid. Signs the query
    /// using the private key of the user associated with the writer.
    ///
    public func groupAddGuid (groupGuid: String, guidToAdd: String, writer: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.AddToGroup,
                             keyPair: writer.keyPair,
            //action: CommandType.AddToGroup.name, //GNSProtocol.ADD_TO_GROUP,
            keysAndValues:
            GNSProtocol.GUID, groupGuid,
            GNSProtocol.MEMBER, guidToAdd,
            GNSProtocol.WRITER, writer.guid)
        return processResponse(sendCommand(command))
    }
    
    // TODO: func groupAddGuids (groupGuid: String, guidsToAdd: NSArray, writer: GuidEntry)
    
    /// Removes a guid from a group guid. Any guid can be a group guid. Signs the
    /// query using the private key of the user associated with the writer.
    ///
    public func groupRemoveGuid (groupGuid: String, guidToRemove: String, writer: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RemoveFromGroup,
                             keyPair: writer.keyPair,
            //action: CommandType.RemoveFromGroup.name, //GNSProtocol.REMOVE_FROM_GROUP,
            keysAndValues:
            GNSProtocol.GUID, groupGuid,
            GNSProtocol.MEMBER, guidToRemove,
            GNSProtocol.WRITER, writer.guid)
        return processResponse(sendCommand(command))
    }
    
    // TODO: func groupRemoveGuids (groupGuid: String, guidsToAdd: NSArray, writer: GuidEntry)
    
    /// Authorize guidToAuthorize to add/remove members from the group groupGuid.
    /// If guidToAuthorize is null, everyone is authorized to add/remove members to
    /// the group. Note that this method can only be called by the group owner
    /// (private key required) Signs the query using the private key of the group
    /// owner.
    ///
    public func groupAddMembershipUpdatePermission(groupGuid: GuidEntry, guidToAuthorize: String?) -> (response: String, error: String) {
        return aclAdd(AclAccessType.WRITE_WHITELIST, targetGuid: groupGuid, field: GNSProtocol.GROUP_ACL, accesserGuid: guidToAuthorize)
    }
    
    /// Unauthorize guidToUnauthorize to add/remove members from the group
    /// groupGuid. If guidToUnauthorize is null, everyone is forbidden to
    /// add/remove members to the group. Note that this method can only be called
    /// by the group owner (private key required). Signs the query using the
    /// private key of the group owner.
    ///
    public func groupRemoveMembershipUpdatePermission(groupGuid: GuidEntry, guidToAuthorize: String?) -> (response: String, error: String) {
        return aclRemove(AclAccessType.WRITE_WHITELIST, targetGuid: groupGuid, field: GNSProtocol.GROUP_ACL, accesserGuid: guidToAuthorize)
    }
    
    /// Authorize guidToAuthorize to get the membership list from the group
    /// groupGuid. If guidToAuthorize is null, everyone is authorized to list
    /// members of the group. Note that this method can only be called by the group
    /// owner (private key required). Signs the query using the private key of the
    /// group owner.
    ///
    public func groupAddMembershipReadPermission(groupGuid: GuidEntry, guidToAuthorize: String?) -> (response: String, error: String) {
        return aclAdd(AclAccessType.READ_WHITELIST, targetGuid: groupGuid, field: GNSProtocol.GROUP_ACL, accesserGuid: guidToAuthorize)
    }
    
    /// Unauthorize guidToUnauthorize to get the membership list from the group
    /// groupGuid. If guidToUnauthorize is null, everyone is forbidden from
    /// querying the group membership. Note that this method can only be called by
    /// the group owner (private key required). Signs the query using the private
    /// key of the group owner.
    ///
    public func groupRemoveMembershipReadPermission(groupGuid: GuidEntry, guidToAuthorize: String?) -> (response: String, error: String) {
        return aclRemove(AclAccessType.READ_WHITELIST, targetGuid: groupGuid, field: GNSProtocol.GROUP_ACL, accesserGuid: guidToAuthorize)
    }
    
    // MARK: Client ACL Commands
    
    /// Adds to an access control list of the given field. The accesser can be a
    /// guid of a user or a group guid or null which means anyone can access the
    /// field. The field can be also be +ALL+ which means all fields can be read by
    /// the reader. Signs the query using the private key of the user associated
    /// with the guid.
    ///
    public func aclAdd(accessType: AclAccessType, targetGuid: GuidEntry, field: String, accesserGuid: String?)
        -> (response: String, error: String) {
        var accesserGuid = accesserGuid;
        if accesserGuid == nil {
            accesserGuid = GNSProtocol.EVERYONE
        }
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.AclAdd,
                             keyPair: targetGuid.keyPair,
            //action: CommandType.AclAdd.name, //GNSProtocol.ACL_ADD,
            keysAndValues:
            GNSProtocol.ACL_TYPE, accessType.description,
            GNSProtocol.GUID, targetGuid.guid,
            GNSProtocol.FIELD, field,
            GNSProtocol.ACCESSER, accesserGuid!)
        return processResponse(sendCommand(command))
    }
    
    /// Removes a GUID from an access control list of the given user's field on the
    /// GNS server to include the guid specified in the accesser param. The
    /// accesser can be a guid of a user or a group guid or null which means anyone
    /// can access the field. The field can be also be +ALL+ which means all fields
    /// can be read by the reader. Signs the query using the private key of the
    /// user associated with the guid.
    ///
    public func aclRemove(accessType: AclAccessType, targetGuid: GuidEntry, field: String, accesserGuid: String?)
        -> (response: String, error: String) {
            var accesserGuid = accesserGuid;
            if accesserGuid == nil {
                accesserGuid = GNSProtocol.EVERYONE
            }
            let command: NSMutableDictionary =
            createAndSignCommand(CommandType.AclRemove,
                                 keyPair: targetGuid.keyPair,
                //action: CommandType.AclRemove.name, //GNSProtocol.ACL_REMOVE,
                keysAndValues:
                GNSProtocol.ACL_TYPE, accessType.description,
                GNSProtocol.GUID, targetGuid.guid,
                GNSProtocol.FIELD, field,
                GNSProtocol.ACCESSER, accesserGuid!)
            return processResponse(sendCommand(command))
    }
    
    /// Get an access control list of the given user's field on the GNS server to
    /// include the guid specified in the accesser param. The accesser can be a
    /// guid of a user or a group guid or null which means anyone can access the
    /// field. The field can be also be +ALL+ which means all fields can be read by
    /// the reader. Signs the query using the private key of the user associated
    /// with the guid.
    ///
    public func aclGet(accessType: AclAccessType, targetGuid: GuidEntry, field: String, accesserGuid: String?)
        -> (response: JSON, error: String) {
            var accesserGuid = accesserGuid
            if accesserGuid == nil {
                accesserGuid = GNSProtocol.EVERYONE
            }
            let command: NSMutableDictionary =
            createAndSignCommand(CommandType.AclRetrieve,
                                 keyPair: targetGuid.keyPair,
                //action: CommandType.AclRetrieve.name, //GNSProtocol.ACL_RETRIEVE,
                keysAndValues:
                GNSProtocol.ACL_TYPE, accessType.description,
                GNSProtocol.GUID, targetGuid.guid,
                GNSProtocol.FIELD, field,
                GNSProtocol.ACCESSER, accesserGuid!)
            return processResponseJSONArray(sendCommand(command))
    }
    
    // MARK: Client Miscellaneous Commands
    
    /// Creates an alias entity name for the given guid. The alias can be used just
    /// like the original entity name.
    ///
    public func addAlias(guid: GuidEntry, name: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.AddAlias,
                             keyPair: guid.keyPair,
            //action: CommandType.AddAlias.name, //GNSProtocol.ADD_ALIAS,
            keysAndValues:
            GNSProtocol.GUID, guid.guid,
            GNSProtocol.NAME, name)
        return processResponse(sendCommand(command))
    }
    
    /// Removes the alias for the given guid.
    ///
    public func removeAlias(guid: GuidEntry, name: String) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RemoveAlias,
                             keyPair: guid.keyPair,
            //action: CommandType.RemoveAlias.name, //GNSProtocol.REMOVE_ALIAS,
            keysAndValues:
            GNSProtocol.GUID, guid.guid,
            GNSProtocol.NAME, name)
        return processResponse(sendCommand(command))
    }
    
    /// Retrieve the aliases associated with the given guid.
    ///
    public func getAliases(guid: GuidEntry) -> (response: JSON, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(CommandType.RetrieveAliases,
                             keyPair: guid.keyPair,
            //action: CommandType.RetrieveAliases.name, //GNSProtocol.RETRIEVE_ALIASES,
            keysAndValues:
            GNSProtocol.GUID, guid.guid)
        return processResponseJSONArray(sendCommand(command))
    }
    
    /// Returns true if we can connect to the server, otherwise returns false.
    ///
    public func checkConnectivity(targetGuid: String) -> Bool {
        let command: NSMutableDictionary =
        // uses the old style read... for now
        createCommand(CommandType.ConnectionCheck) //GNSProtocol.CONNECTION_CHECK)
        let (_, error) = processResponse(sendCommand(command))
        if error.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Initialization Methods
    
    /// Opens a connection to the remote host specfied by host and port as well as listetning on listenPort.
    ///
    private func openAndListen() -> Bool {
        if debuggingEnabled {print("#####open Connection")}
        asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: outgoingQueue)
        var error: NSError?
        do {
            try asyncSocket!.connectToHost(serverHost, onPort: serverPort)
        } catch let error1 as NSError {
            error = error1
            if error != nil {
                print("Error connecting \(error!.localizedDescription)")
            }
        }
        //if (duplexNIO) {
            // we'll be reading on the return channel of the asyncSocket
            asyncSocket!.readDataWithTimeout(-1, tag:49)
//        } else {
//            // old style hald-duplex - we need to create a listening socket
//            if (!duplexNIO) {
//                acceptSocket = GCDAsyncSocket(delegate: self, delegateQueue: incomingQueue)
//                do {
//                    try acceptSocket!.acceptOnPort(listenPort)
//                } catch let error1 as NSError {
//                    error = error1
//                    if error != nil {
//                        print("Error connecting \(error!.localizedDescription)")
//                    }
//                }
//                if debuggingEnabled {print("#####Waiting for connect on \(acceptSocket!.localPort)")}
//            }
//        }
        
        // wait for the didConnectToHost call back to happen before we return
        var timeout:Int = 0 // if not zero it is a timeout
        timeout = dispatch_semaphore_wait(connectSemaphore, Utils.delayInSeconds(openTimeout));
        if timeout != 0 {
            return false
        } else {
            return true
        }
    }
    
    // MARK: Delegate Methods
    
    /// Delegate method that signals the connectSemaphore when the remote hosts connects
    ///
    func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port:UInt16) {
        if debuggingEnabled {print("#####Connected to \(host):\(port)")}
        let wokeThread = dispatch_semaphore_signal(connectSemaphore);
        if debuggingEnabled {print("#####Connect signal was \(wokeThread)")}
    }
    
    /// Not really needed for anything
    ///
    func socket(socket : GCDAsyncSocket, didWriteDataWithTag tag:Int32) {
        //println("#####Wrote \(tag)")
    }
    
    /// Delegate method that sets up the first read when we accept on the listening socket
    ///
    func socket(socket : GCDAsyncSocket, didAcceptNewSocket newSocket:GCDAsyncSocket) {
        // Important to bind newSocket here otherwise it gets deallocated which
        // closes it which is bad.
        readSocket = newSocket
        readSocket!.readDataWithTimeout(-1, tag:50)
    }
    
    /// Delegate method that handles the data we got during a read. 
    /// Also sets up the next read.
    ///
    /// FIXME: Verify that we don't lose any data under heavier load
    ///
    func socket(socket: GCDAsyncSocket, didReadData data:NSData, withTag tag:Int32) {
        //if let message = Utils.NSDataToString(data) {
        // Important to use the same encoding that NIO uses
        
        let (strings, leftover) = MessageExtractor.extractMultipleMessages(data)
        if !leftover.isEmpty {
            if debuggingEnabled {print("#####This data leftover: \(leftover)")}
        }
        for string in strings {
            handleReturnPacket(string)
        }
        
        
//        if let message = Utils.NSDataToString(data, encoding: GNSProtocol.NIO_CHARSET_ENCODING) {
//            let (strings, leftover) = MessageExtractor.extractMultipleMessages(message)
//            if !leftover.isEmpty {
//                if debuggingEnabled {println("#####This data leftover: \(leftover)")}
//            }
//            for string in strings {
//                handleReturnPacket(string)
//            }
//        }
        
        // VERY IMPORTANT!! Set up the next read.
        socket.readDataWithTimeout(-1, tag: 51)
    }
    
    /// Not really needed for anything
    ///
    func socketDidDisconnect(socket : GCDAsyncSocket, withError err:NSError) {
        if debuggingEnabled {
            print("#####Disconnect")
        }
    }
    
    // MARK: Support Methods
    
    /// Converts a NSMutableDictionary into JSON Encoded NSData that can be sent over a socket
    ///
    private func createJSONNSData(jsonObj: AnyObject) -> NSData {
        var e: NSError?
        let jsonData: NSData!
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(
                        jsonObj,
                        options: NSJSONWritingOptions(rawValue: 0))
        } catch let error as NSError {
            e = error
            jsonData = nil
        }
        if e != nil {
            return NSData();
        } else {
            return jsonData;
        }
    }
    
    // FIXME: JSON Object Representation
    // We'll stick with NSMutableDictionary as our JSON representation until we get a
    // JSON class that can call NSJSONSerialization.dataWithJSONObject to generate the 
    // serial form.
    
    /// Creates a command object.
    ///
    internal func createCommand(commandType: CommandType, keysAndValues: NSCopying...) -> NSMutableDictionary {
        let mutableDict: NSMutableDictionary = NSMutableDictionary()
        mutableDict.setObject(commandType.name, forKey: GNSProtocol.COMMANDNAME)
        mutableDict.setObject(commandType.number, forKey: GNSProtocol.COMMAND_INT)
        for i in (0..<keysAndValues.count) where i % 2 == 0 {
        //for (var i = 0; i < keysAndValues.count; i = i + 2) {
            mutableDict.setObject(keysAndValues[i + 1], forKey: keysAndValues[i])
        }
        return mutableDict
    }
    
    /// Creates a command object from the given action string and a variable
    /// number of key and value pairs with a signature parameter. The signature is
    /// generated from the command signed by the given guid.
    ///
    internal func createAndSignCommand(commandType: CommandType, keyPair: KeyPair, keysAndValues: NSCopying...) -> NSMutableDictionary {
        let mutableDict: NSMutableDictionary = NSMutableDictionary()
        mutableDict.setObject(commandType.name, forKey: GNSProtocol.COMMANDNAME)
        mutableDict.setObject(commandType.number, forKey: GNSProtocol.COMMAND_INT)
        for i in (0..<keysAndValues.count) where i % 2 == 0 {
        //for (var i = 0; i < keysAndValues.count; i = i + 2) {
            mutableDict.setObject(keysAndValues[i + 1], forKey: keysAndValues[i])
        }
        let json = JSON(object: mutableDict)
        let canonicalJSON = json.toStringCanonical
//        println("#####CANONICAL JSON:\(canonicalJSON)")
        let signedJSON: NSData = keyPair.signBytesSHA1withRSA(Utils.StringToNSData(canonicalJSON))
        mutableDict.setObject(signedJSON.hexadecimalString(), forKey: GNSProtocol.SIGNATURE)
        return mutableDict
    }
    
    /// Parses a reponse string from the server. If it isn't an error response returns the
    /// response as a string.
    ///
    internal func processResponse(response: String) -> (response: String, error: String) {
        if response.characters.startsWith(GNSProtocol.BAD_RESPONSE.characters) {
            // should look like  "+NO+<space><error string><space><other info>
            let errorParts = response.componentsSeparatedByString(" ")
            if errorParts.count < 2 {
                return ("", "Nested error: badly formed error response: \(response)")
            } else if errorParts.count == 2 {
                return ("", errorParts[1])
            } else {
                // for now we won't worry about too much parsing, just return error and other info
                let error = errorParts[1]
                var rest = ""
                var prefix = ""
                for parts in errorParts[2..<errorParts.endIndex] {
                    rest = rest + prefix
                    rest = rest + parts
                    prefix = " "
                }
                return ("", error + " " + rest)
            }
        } else {
            return (response, "")
        }
    }
    
    /// Parses a reponse string from the server. If it isn't an error response returns the
    /// response as a JSONObject.
    ///
    internal func processResponseJSONObject(response: String) -> (response: JSON, error: String) {
        let (response, errorString) = processResponse(response)
        if errorString.isEmpty {
            var error : NSError?
            if let jsonData = response.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let jsonObject: JSON = JSON(data: jsonData, options: [], error: &error)
                if error != nil {
                    return (JSON(), "error parsing returned JSON")
                } else {
                    return (jsonObject, "")
                }
            } else {
                return (JSON(), "error reading returned JSON")
            }
        } else {
            return (JSON(), errorString)
        }
    }
    
    /// Parses a reponse string from the server. If it isn't an error response returns the
    /// response as an NSArray (our JSONArray).
    ///
    internal func processResponseJSONArray(response: String) -> (response: JSON, error: String) {
        let (response, errorString) = processResponse(response)
        if errorString.isEmpty {
            var error : NSError?
            if let jsonData = response.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let jsonArray: JSON = JSON(data: jsonData, options: [], error: &error)
                if error != nil {
                    return (JSON(), "error parsing returned JSON")
                } else {
                    return (jsonArray, "")
                }
            } else {
                return (JSON(), "error reading returned JSON")
            }
        } else {
            return (JSON(), errorString)
        }
    }

    /// Creates a command packet which can be sent over the outgoing socket.
    ///
    /// As of 12/14 and duplexNIO you basically never want to specify senderHost and senderPort as anything other than nil and -1.
    ///
    internal func createCommandPacket(requestID: Int,
                                      //senderHost: String?, senderPort: Int,
                                      command: NSMutableDictionary) -> NSData {
        let mutableDict: NSMutableDictionary = NSMutableDictionary()
        mutableDict.setObject(GNSProtocol.COMMAND_PACKET_PACKET_TYPE, forKey: GNSProtocol.COMMAND_PACKET_PACKET_TYPE_FIELD)
        mutableDict.setObject(requestID, forKey: GNSProtocol.COMMAND_PACKET_REQUESTID)
        // ALSO INCLUDE OLD ONE FOR COMPATIBILITY
        mutableDict.setObject(requestID, forKey: GNSProtocol.OLD_COMMAND_PACKET_REQUESTID)
        // If this is not specified it will be filled in by the NIO receiver on the other end.
        // As of 12/14 and duplexNIO you basically never want to specify senderHost and senderPort as anything other than nil and -1.
//        if (senderHost != nil) {
//          mutableDict.setObject(senderHost!, forKey: GNSProtocol.COMMAND_PACKET_DEFAULT_IP_FIELD)
//        }
//        if (senderPort != -1) {
//            mutableDict.setObject(senderPort, forKey: GNSProtocol.COMMAND_PACKET_DEFAULT_PORT_FIELD)
//        }
        mutableDict.setObject(command, forKey: GNSProtocol.COMMAND_PACKET_COMMAND)
        // ALSO INCLUDE OLD ONE FOR COMPATIBILITY
        mutableDict.setObject(command, forKey: GNSProtocol.OLD_COMMAND_PACKET_COMMAND)
        return createJSONNSData(mutableDict);
    }
    
    /// Keeps track of the responses coming back from the server.
    ///
    private var resultMap = Dictionary<Int, JSON>(minimumCapacity: 2)
    
    /// Sends a command packet to the remote server.
    ///
    internal func sendCommand(command: NSMutableDictionary) -> String {
        let id: Int = nextRequestId()
        // As of 12/14 and duplexNIO NAT support is built in to the server.
        let commandPacket: NSData =
        //duplexNIO ?
            // the server handles all of the host and port stamping
            createCommandPacket(id,
                //senderHost: nil,
                //senderPort: -1,
                command: command)
//            :
//            // old style, half-duplex we need to stamp things
//            createCommandPacket(id,
//                senderHost: asyncSocket!.localHost,
//                senderPort: Int(acceptSocket!.localPort),
//                command: command)
        
        // commandPacket is UTF-8 encoded, but NIO uses ISO-8859-1 so we add
        // some hair here to do that
       
        let headeredMsg: NSData = MessageExtractor.prependHeader(commandPacket)
//        if debuggingEnabled {
//            println("#####Sending: " + Utils.NSDataToString(headeredMsg,
//                encoding: GNSProtocol.NIO_CHARSET_ENCODING)!)
//        }
        asyncSocket!.writeData(headeredMsg, withTimeout:-1, tag: id);
        if debuggingEnabled {
            print("#####Waiting")
        }
        var timeout:Int = 0 // if not zero it is a timeout
        while (self.resultMap[id] == nil) {
            timeout = dispatch_semaphore_wait(self.readSemaphore, Utils.delayInSeconds(readTimeout));
            if debuggingEnabled {
                print("#####Checking timeout: \(timeout)")
            }
            if timeout != 0 {
                return GNSProtocol.BAD_RESPONSE + " " + GNSProtocol.TIMEOUT
            }
        }
        //
        if let json = resultMap[id] {
            resultMap.removeValueForKey(id)
            if let resultString = json[GNSProtocol.COMMAND_RETURN_PACKET_RETURNVALUE].stringValue {
                return resultString
            } else
            // ALSO SUPPORT OLDER RETURN VALUE PACKET FIELD
            if let resultString = json[GNSProtocol.OLD_COMMAND_RETURN_PACKET_RETURNVALUE].stringValue {
                return resultString
            }
        }
        // Only happens if we get a packet that is missing a return value... which should not happen.
        return ""
    }
    
    /// Called when we get return packets from the server.
    ///
    private func handleReturnPacket(packetString: String) {
        let json = JSON(data: Utils.StringToNSData(packetString))
        // critical code
        if let requestID = json[GNSProtocol.COMMAND_RETURN_PACKET_REQUESTID].integerValue {
            //println("#####Read requestID = \(requestID)")
            self.resultMap.updateValue(json, forKey:requestID)
        } else
            // ALSO SUPPORT OLDER RETURN VALUE PACKET FIELD
            if let requestID = json[GNSProtocol.OLD_COMMAND_RETURN_PACKET_REQUESTID].integerValue {
            //println("#####Read requestID = \(requestID)")
            self.resultMap.updateValue(json, forKey:requestID)
        }
        _ = dispatch_semaphore_signal(self.readSemaphore);
        //println("#####Read signal was \(wokeThread)")
    }
    
    /// Geerates the next request id.
    private func nextRequestId() -> Int {
        var id: Int
        repeat {
            // Limit it to Int32 because so we can use it as a tag in async code
            id = Int(arc4random_uniform(UInt32(Int32.max)))
        } while (resultMap[id] != nil)
        return id;
    }
    
}
