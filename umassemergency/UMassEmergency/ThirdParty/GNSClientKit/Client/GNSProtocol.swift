//
//  GNSProtocol.swift
//  GnsClientIOS
//
//  Version 18 - 5/25/16
//
//  Created by David Westbrook on 10/29/14.
//  Copyright (c) 2014 University of Massachusetts.
//

import Foundation

public struct GNSProtocol {
    // Generated from the java sources, do not edit.
    public static let OK_RESPONSE				 = "+OK+"
    public static let BAD_RESPONSE				 = "+NO+"
    public static let UNSPECIFIED_ERROR				 = "+GENERICERROR+"
    public static let BAD_SIGNATURE				 = "+BAD_SIGNATURE+"
    public static let ACCESS_DENIED				 = "+ACCESS_DENIED+"
    public static let STALE_COMMMAND				 = "+STALE_COMMMAND+"
    public static let OPERATION_NOT_SUPPORTED				 = "+OPERATIONNOTSUPPORTED+"
    public static let QUERY_PROCESSING_ERROR				 = "+QUERYPROCESSINGERROR+"
    public static let VERIFICATION_ERROR				 = "+VERIFICATIONERROR+"
    public static let ALREADY_VERIFIED_EXCEPTION				 = "+ALREADYVERIFIED+"
    public static let REMOTE_QUERY_EXCEPTION				 = "+REMOTEQUERY+"
    public static let BAD_ACCESSOR_GUID				 = "+BADACCESSORGUID+"
    public static let BAD_GUID				 = "+BADGUID+"
    public static let BAD_ACCOUNT				 = "+BADACCOUNT+"
    public static let BAD_ALIAS				 = "+BADALIAS+"
    public static let BAD_ACL_TYPE				 = "+BADACLTYPE+"
    public static let FIELD_NOT_FOUND				 = "+FIELDNOTFOUND+"
    public static let DUPLICATE_GUID				 = "+DUPLICATEGUID+"
    public static let DUPLICATE_FIELD				 = "+DUPLICATEFIELD+"
    public static let DUPLICATE_NAME				 = "+DUPLICATENAME+"
    public static let JSON_PARSE_ERROR				 = "+JSONPARSEERROR+"
    public static let TOO_MANY_ALIASES				 = "+TOMANYALIASES+"
    public static let TOO_MANY_GUIDS				 = "+TOMANYGUIDS+"
    public static let UPDATE_ERROR				 = "+UPDATEERROR+"
    public static let DATABASE_OPERATION_ERROR				 = "+DATABASEOPERROR+"
    public static let TIMEOUT				 = "+TIMEOUT+"
    public static let ACTIVE_REPLICA_EXCEPTION				 = "ACTIVE_REPLICA_EXCEPTION"
    public static let NULL_RESPONSE				 = "+NULL+"
    public static let RSA_ALGORITHM				 = "RSA"
    public static let SIGNATURE_ALGORITHM				 = "SHA1withRSA"
    public static let DIGEST_ALGORITHM				 = "SHA1"
    public static let SECRET_KEY_ALGORITHM				 = "DESede"
    public static let CHARSET				 = "ISO-8859-1"
    public static let GUID				 = "guid"
    public static let NAME				 = "name"
    public static let NAMES				 = "names"
    public static let ACCOUNT_GUID				 = "accountGuid"
    public static let READER				 = "reader"
    public static let WRITER				 = "writer"
    public static let ACCESSER				 = "accesser"
    public static let FIELD				 = "field"
    public static let FIELDS				 = "fields"
    public static let VALUE				 = "value"
    public static let OLD_VALUE				 = "oldvalue"
    public static let USER_JSON				 = "userjson"
    public static let ARGUMENT				 = "argument"
    public static let N				 = "n"
    public static let MEMBER				 = "member"
    public static let MEMBERS				 = "members"
    public static let ACL_TYPE				 = "aclType"
    public static let PUBLIC_KEY				 = "publickey"
    public static let PUBLIC_KEYS				 = "publickeys"
    public static let PASSWORD				 = "password"
    public static let CODE				 = "code"
    public static let SIGNATURE				 = "signature"
    public static let WITHIN				 = "within"
    public static let NEAR				 = "near"
    public static let MAX_DISTANCE				 = "maxDistance"
    public static let QUERY				 = "query"
    public static let INTERVAL				 = "interval"
    public static let ENTIRE_RECORD				 = "+ALL+"
    public static let ALL_GUIDS				 = "+ALL+"
    public static let EVERYONE				 = "+ALL+"
    public static let LOG_LEVEL				 = "level"
    public static let GUIDCNT				 = "guidCnt"
    public static let TIMESTAMP				 = "timestamp"
    public static let NONCE				 = "seqnum"
    public static let PASSKEY				 = "passkey"
    public static let SIGNATUREFULLMESSAGE				 = "_signatureFullMessage_"
    public static let GROUP_ACL				 = "+GROUP_ACL+"
    public static let GUID_RECORD_PUBLICKEY				 = "publickey"
    public static let GUID_RECORD_NAME				 = "name"
    public static let GUID_RECORD_GUID				 = "guid"
    public static let GUID_RECORD_TYPE				 = "type"
    public static let GUID_RECORD_CREATED				 = "created"
    public static let GUID_RECORD_UPDATED				 = "updated"
    public static let GUID_RECORD_TAGS				 = "tags"
    public static let ACCOUNT_RECORD_VERIFIED				 = "verified"
    public static let ACCOUNT_RECORD_GUIDS				 = "guids"
    public static let ACCOUNT_RECORD_GUID				 = "guid"
    public static let ACCOUNT_RECORD_USERNAME				 = "username"
    public static let ACCOUNT_RECORD_CREATED				 = "created"
    public static let ACCOUNT_RECORD_UPDATED				 = "updated"
    public static let ACCOUNT_RECORD_TYPE				 = "type"
    public static let ACCOUNT_RECORD_PASSWORD				 = "password"
    public static let ACCOUNT_RECORD_ALIASES				 = "aliases"
    public static let LOCATION_FIELD_NAME				 = "geoLocation"
    public static let LOCATION_FIELD_NAME_2D_SPHERE				 = "geoLocationCurrent"
    public static let IPADDRESS_FIELD_NAME				 = "netAddress"
    public static let COMMAND_INT				 = "COMMANDINT"
    public static let COMMANDNAME				 = "COMMANDNAME"
    public static let FORCE_COORDINATE_READS				 = "COORDREAD"
    public static let AC_ACTION				 = "acAction"
    public static let AC_CODE				 = "acCode"
    public static let INTERNAL_PREFIX				 = "_GNS_"
    public static let ORIGINATING_GUID				 = "OGUID"
    public static let ORIGINATING_QID				 = "OQID"
    public static let REQUEST_TTL				 = "QTTL"
    public static let REQUEST_ID				 = "QID"
    public static let RETURN_VALUE				 = "RVAL"
    public static let COMMAND_QUERY				 = "QVAL"
    public static let SERVICE_NAME				 = "NAME"
    public static let UNKNOWN_NAME				 = "unknown"
    public static let ERROR_CODE				 = "ECODE"
    public static let INTERNAL_REQUEST_EXCEPTION				 = "+INTERNAL_REQUEST_EXCEPTION+"
    public static let COORD1				 = "COORD1"
    
    
    // Additional parameters not generated
    
    // First thing is not really part of the protocol, but is an NIO thing.
    public static let NIO_CHARSET_ENCODING:UInt = NSISOLatin1StringEncoding; //AKA ISO-8859-1 which is what NIO uses
    
    //
    // FROM CommandPacket
    public static let OLD_COMMAND_PACKET_REQUESTID   = "clientreqID";
    public static let COMMAND_PACKET_REQUESTID       = "QID";
    public static let OLD_COMMAND_PACKET_COMMAND     = "command";
    public static let COMMAND_PACKET_COMMAND         = "QVAL";
    
    // FROM edu.umass.cs.nio.MessageNIOTransport
    public static let COMMAND_PACKET_DEFAULT_IP_FIELD    = "_SNDR_IP_ADDRESS";
    public static let COMMAND_PACKET_DEFAULT_PORT_FIELD = "_SNDR_TCP_PORT";
    // FROM Packet
    public static let COMMAND_PACKET_PACKET_TYPE_FIELD = "type";
    public static let COMMAND_PACKET_PACKET_TYPE = 7;
    // FROM CommandReturnValuePacket
    public static let OLD_COMMAND_RETURN_PACKET_REQUESTID    = "clientreqID";
    public static let COMMAND_RETURN_PACKET_REQUESTID        = "QID";
    public static let OLD_COMMAND_RETURN_PACKET_RETURNVALUE  = "returnValue";
    public static let COMMAND_RETURN_PACKET_RETURNVALUE      = "RVAL";
    public static let OLD_COMMAND_RETURN_PACKET_ERRORCODE    = "errorCode";
    public static let COMMAND_RETURN_PACKET_ERRORCODE        = "ECODE";
    public static let COMMAND_RETURN_PACKET_LNSROUNDTRIPTIME = "ccpRtt";
    public static let COMMAND_RETURN_PACKET_RESPONDER        = "responder";
    public static let COMMAND_RETURN_PACKET_REQUESTCNT       = "requestCnt";
    public static let COMMAND_RETURN_PACKET_REQUESTRATE      = "requestRate";
}

public enum AclAccessType : CustomStringConvertible {
    /**
     * Whitelist of GUIDs authorized to read a field
     */
    case READ_WHITELIST
    /**
     * Whitelist of GUIDs authorized to write/update a field
     */
    case WRITE_WHITELIST
    /**
     * Black list of GUIDs not authorized to read a field
     */
    case READ_BLACKLIST
    /**
     * Black list of GUIDs not authorized to write/update a field
     */
    case WRITE_BLACKLIST
    
    public var description : String {
        switch self {
            // Use Internationalization, as appropriate.
            case .READ_WHITELIST:  return "READ_WHITELIST"
            case .WRITE_WHITELIST: return "WRITE_WHITELIST"
            case .READ_BLACKLIST:  return "READ_BLACKLIST"
            case .WRITE_BLACKLIST: return "WRITE_BLACKLIST"
        }
    }

}
