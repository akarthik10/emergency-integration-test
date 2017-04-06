//
//  ExtendedTCPClient.swift
//  GnsClientIOS
//
//  Created by David Westbrook on 11/19/14.
//  Copyright (c) 2014 David Westbrook. All rights reserved.
//

import Foundation

/// This class defines some additions (not using the word "extensions" here because that means
/// something specific in Swift) to the BasicTCPClient. Specifically, explicit support for
/// getting and setting a geolocation as well as select methods that operate on geolocs. And
/// the general select method that returns all guids with a field and value.
///
/// @author <a href="mailto:westy@cs.umass.edu">Westy</a>
///
public class ExtendedTCPClient: BasicTCPClient {
    
    /// Uses the "older" array based protocol to update a field in the targetGuid with a JSONArray. 
    /// The JSON value should be an array.
    /// The writer is the guid of the user attempting access. Signs the query using 
    /// the private key of the writer guid.
    ///
    public func fieldReplaceOrCreateList (targetGuid: String, field: String, value: JSON, writer: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(writer.keyPair,
            action: GNSProtocol.REPLACE_OR_CREATE_LIST,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, field,
            // Due to the way the "older" code handles arrays on the server side 
            // we actually convert this to a string before sending.
            GNSProtocol.VALUE, value.toString,
            GNSProtocol.WRITER, writer.guid)
        return processResponse(sendCommand(command))
    }
    

    /// Reads the field which is an array from the GNS server for the given guid. The
    /// guid of the user attempting access is also needed. Signs the query using
    /// the private key of the user associated with the reader guid (unsigned if
    /// reader is null).
    ///
    public func fieldReadArray (targetGuid: String, field: String, reader: GuidEntry) -> (response: String, error: String) {
        let command: NSMutableDictionary =
        createAndSignCommand(reader.keyPair,
            action: GNSProtocol.READ_ARRAY,
            keysAndValues:
            GNSProtocol.GUID, targetGuid,
            GNSProtocol.FIELD, field,
            GNSProtocol.READER, reader.guid)
        return processResponse(sendCommand(command))
    }
    
    public func setLocation(targetGuid: String, longitude:Double, latitude:Double, writer: GuidEntry) -> (response: String, error: String) {
        let jsonArray = JSON(object: [longitude,latitude])
        return fieldReplaceOrCreateList(targetGuid, field: GNSProtocol.LOCATION_FIELD_NAME, value: jsonArray, writer: writer)
    }
    
    public func getLocation(targetGuid: String, reader: GuidEntry) -> (response: String, error: String) {
        return fieldReadArray(targetGuid, field:GNSProtocol.LOCATION_FIELD_NAME, reader: reader)
    }
    
    // MARK: Select Commands
    
    public func select (field: String, value: String) -> (response: JSON, error: String) {
        let command: NSMutableDictionary =
        createCommand(GNSProtocol.SELECT,
            keysAndValues:
            GNSProtocol.FIELD, field,
            GNSProtocol.VALUE, value)
        return processResponseJSONArray(sendCommand(command))
    }
    
    public func selectWithin (field: String, long1:Double, lat1:Double, long2:Double, lat2:Double ) -> (response: JSON, error: String) {
        let jsonArray = JSON(object: [[long1,lat1], [long2,lat2]])
        let command: NSMutableDictionary =
        createCommand(GNSProtocol.SELECT_WITHIN,
            keysAndValues:
            GNSProtocol.FIELD, field,
            GNSProtocol.WITHIN, jsonArray.toString
        )
        return processResponseJSONArray(sendCommand(command))
    }
    
    public func selectNear (field: String, longitude:Double, latitude:Double, distance:Double) -> (response: JSON, error: String) {
        let jsonArray = JSON(object: [longitude,latitude])
        let command: NSMutableDictionary =
        createCommand(GNSProtocol.SELECT_NEAR,
            keysAndValues:
            GNSProtocol.FIELD, field,
            GNSProtocol.NEAR, jsonArray.toString,
            GNSProtocol.MAX_DISTANCE, distance
        )
        return processResponseJSONArray(sendCommand(command))
    }
    
   
}