//
//  GNSProtocol.swift
//  GnsClientIOS
//
//  Version 18 - 5/25/16
//
//  Created by David Westbrook on 10/29/14.
//  Copyright (c) 2014 University of Massachusetts. All rights reserved.
//

import Foundation

public struct GNSProtocol {
    // First thing is not really part of the protocol, but is an NIO thing.
    public static let NIO_CHARSET_ENCODING:UInt = NSISOLatin1StringEncoding; //AKA ISO-8859-1 which is what NIO uses
    // New recoded list based on CommandType enum in Java.
    public static let APPEND				 = "Append"
    public static let APPEND_LIST				 = "AppendList"
    public static let APPEND_LIST_SELF				 = "AppendListSelf"
    public static let APPEND_LIST_UNSIGNED				 = "AppendListUnsigned"
    public static let APPEND_LIST_WITH_DUPLICATION				 = "AppendListWithDuplication"
    public static let APPEND_LIST_WITH_DUPLICATION_SELF				 = "AppendListWithDuplicationSelf"
    public static let APPEND_LIST_WITH_DUPLICATION_UNSIGNED				 = "AppendListWithDuplicationUnsigned"
    public static let APPEND_OR_CREATE				 = "AppendOrCreate"
    public static let APPEND_OR_CREATE_LIST				 = "AppendOrCreateList"
    public static let APPEND_OR_CREATE_LIST_SELF				 = "AppendOrCreateListSelf"
    public static let APPEND_OR_CREATE_LIST_UNSIGNED				 = "AppendOrCreateListUnsigned"
    public static let APPEND_OR_CREATE_SELF				 = "AppendOrCreateSelf"
    public static let APPEND_OR_CREATE_UNSIGNED				 = "AppendOrCreateUnsigned"
    public static let APPEND_SELF				 = "AppendSelf"
    public static let APPEND_UNSIGNED				 = "AppendUnsigned"
    public static let APPEND_WITH_DUPLICATION				 = "AppendWithDuplication"
    public static let APPEND_WITH_DUPLICATION_SELF				 = "AppendWithDuplicationSelf"
    public static let APPEND_WITH_DUPLICATION_UNSIGNED				 = "AppendWithDuplicationUnsigned"
    public static let CLEAR				 = "Clear"
    public static let CLEAR_SELF				 = "ClearSelf"
    public static let CLEAR_UNSIGNED				 = "ClearUnsigned"
    public static let CREATE				 = "Create"
    public static let CREATE_EMPTY				 = "CreateEmpty"
    public static let CREATE_EMPTY_SELF				 = "CreateEmptySelf"
    public static let CREATE_LIST				 = "CreateList"
    public static let CREATE_LIST_SELF				 = "CreateListSelf"
    public static let CREATE_SELF				 = "CreateSelf"
    public static let READ				 = "Read"
    public static let READ_SELF				 = "ReadSelf"
    public static let READ_UNSIGNED				 = "ReadUnsigned"
    public static let READ_MULTI_FIELD				 = "ReadMultiField"
    public static let READ_MULTI_FIELD_UNSIGNED				 = "ReadMultiFieldUnsigned"
    public static let READ_ARRAY				 = "ReadArray"
    public static let READ_ARRAY_ONE				 = "ReadArrayOne"
    public static let READ_ARRAY_ONE_SELF				 = "ReadArrayOneSelf"
    public static let READ_ARRAY_ONE_UNSIGNED				 = "ReadArrayOneUnsigned"
    public static let READ_ARRAY_SELF				 = "ReadArraySelf"
    public static let READ_ARRAY_UNSIGNED				 = "ReadArrayUnsigned"
    public static let REMOVE				 = "Remove"
    public static let REMOVE_LIST				 = "RemoveList"
    public static let REMOVE_LIST_SELF				 = "RemoveListSelf"
    public static let REMOVE_LIST_UNSIGNED				 = "RemoveListUnsigned"
    public static let REMOVE_SELF				 = "RemoveSelf"
    public static let REMOVE_UNSIGNED				 = "RemoveUnsigned"
    public static let REPLACE				 = "Replace"
    public static let REPLACE_LIST				 = "ReplaceList"
    public static let REPLACE_LIST_SELF				 = "ReplaceListSelf"
    public static let REPLACE_LIST_UNSIGNED				 = "ReplaceListUnsigned"
    public static let REPLACE_OR_CREATE				 = "ReplaceOrCreate"
    public static let REPLACE_OR_CREATE_LIST				 = "ReplaceOrCreateList"
    public static let REPLACE_OR_CREATE_LIST_SELF				 = "ReplaceOrCreateListSelf"
    public static let REPLACE_OR_CREATE_LIST_UNSIGNED				 = "ReplaceOrCreateListUnsigned"
    public static let REPLACE_OR_CREATE_SELF				 = "ReplaceOrCreateSelf"
    public static let REPLACE_OR_CREATE_UNSIGNED				 = "ReplaceOrCreateUnsigned"
    public static let REPLACE_SELF				 = "ReplaceSelf"
    public static let REPLACE_UNSIGNED				 = "ReplaceUnsigned"
    public static let REPLACE_USER_JSON				 = "ReplaceUserJSON"
    public static let REPLACE_USER_JSON_UNSIGNED				 = "ReplaceUserJSONUnsigned"
    public static let CREATE_INDEX				 = "CreateIndex"
    public static let SUBSTITUTE				 = "Substitute"
    public static let SUBSTITUTE_LIST				 = "SubstituteList"
    public static let SUBSTITUTE_LIST_SELF				 = "SubstituteListSelf"
    public static let SUBSTITUTE_LIST_UNSIGNED				 = "SubstituteListUnsigned"
    public static let SUBSTITUTE_SELF				 = "SubstituteSelf"
    public static let SUBSTITUTE_UNSIGNED				 = "SubstituteUnsigned"
    public static let REMOVE_FIELD				 = "RemoveField"
    public static let REMOVE_FIELD_SELF				 = "RemoveFieldSelf"
    public static let REMOVE_FIELD_UNSIGNED				 = "RemoveFieldUnsigned"
    public static let SET				 = "Set"
    public static let SET_SELF				 = "SetSelf"
    public static let SET_FIELD_NULL				 = "SetFieldNull"
    public static let SET_FIELD_NULL_SELF				 = "SetFieldNullSelf"
    public static let SELECT				 = "Select"
    public static let SELECT_GROUP_LOOKUP_QUERY				 = "SelectGroupLookupQuery"
    public static let SELECT_GROUP_SETUP_QUERY				 = "SelectGroupSetupQuery"
    public static let SELECT_GROUP_SETUP_QUERY_WITH_GUID				 = "SelectGroupSetupQueryWithGuid"
    public static let SELECT_GROUP_SETUP_QUERY_WITH_GUID_AND_INTERVAL				 = "SelectGroupSetupQueryWithGuidAndInterval"
    public static let SELECT_GROUP_SETUP_QUERY_WITH_INTERVAL				 = "SelectGroupSetupQueryWithInterval"
    public static let SELECT_NEAR				 = "SelectNear"
    public static let SELECT_WITHIN				 = "SelectWithin"
    public static let SELECT_QUERY				 = "SelectQuery"
    public static let ADD_ALIAS				 = "AddAlias"
    public static let ADD_GUID				 = "AddGuid"
    public static let ADD_MULTIPLE_GUIDS				 = "AddMultipleGuids"
    public static let ADD_MULTIPLE_GUIDS_FAST				 = "AddMultipleGuidsFast"
    public static let ADD_MULTIPLE_GUIDS_FAST_RANDOM				 = "AddMultipleGuidsFastRandom"
    public static let LOOKUP_ACCOUNT_RECORD				 = "LookupAccountRecord"
    public static let LOOKUP_RANDOM_GUIDS				 = "LookupRandomGuids"
    public static let LOOKUP_GUID				 = "LookupGuid"
    public static let LOOKUP_PRIMARY_GUID				 = "LookupPrimaryGuid"
    public static let LOOKUP_GUID_RECORD				 = "LookupGuidRecord"
    public static let REGISTER_ACCOUNT				 = "RegisterAccount"
    public static let REGISTER_ACCOUNT_SANS_PASSWORD				 = "RegisterAccountSansPassword"
    public static let REGISTER_ACCOUNT_UNSIGNED				 = "RegisterAccountUnsigned"
    public static let REMOVE_ACCOUNT				 = "RemoveAccount"
    public static let REMOVE_ALIAS				 = "RemoveAlias"
    public static let REMOVE_GUID				 = "RemoveGuid"
    public static let REMOVE_GUID_NO_ACCOUNT				 = "RemoveGuidNoAccount"
    public static let RETRIEVE_ALIASES				 = "RetrieveAliases"
    public static let SET_PASSWORD				 = "SetPassword"
    public static let VERIFY_ACCOUNT				 = "VerifyAccount"
    public static let RESET_KEY				 = "ResetKey"
    public static let ACL_ADD				 = "AclAdd"
    public static let ACL_ADD_SELF				 = "AclAddSelf"
    public static let ACL_REMOVE				 = "AclRemove"
    public static let ACL_REMOVE_SELF				 = "AclRemoveSelf"
    public static let ACL_RETRIEVE				 = "AclRetrieve"
    public static let ACL_RETRIEVE_SELF				 = "AclRetrieveSelf"
    public static let ADD_MEMBERS_TO_GROUP				 = "AddMembersToGroup"
    public static let ADD_MEMBERS_TO_GROUP_SELF				 = "AddMembersToGroupSelf"
    public static let ADD_TO_GROUP				 = "AddToGroup"
    public static let ADD_TO_GROUP_SELF				 = "AddToGroupSelf"
    public static let GET_GROUP_MEMBERS				 = "GetGroupMembers"
    public static let GET_GROUP_MEMBERS_SELF				 = "GetGroupMembersSelf"
    public static let GET_GROUPS				 = "GetGroups"
    public static let GET_GROUPS_SELF				 = "GetGroupsSelf"
    public static let REMOVE_FROM_GROUP				 = "RemoveFromGroup"
    public static let REMOVE_FROM_GROUP_SELF				 = "RemoveFromGroupSelf"
    public static let REMOVE_MEMBERS_FROM_GROUP				 = "RemoveMembersFromGroup"
    public static let REMOVE_MEMBERS_FROM_GROUP_SELF				 = "RemoveMembersFromGroupSelf"
    public static let HELP				 = "Help"
    public static let HELP_TCP				 = "HelpTcp"
    public static let HELP_TCP_WIKI				 = "HelpTcpWiki"
    public static let ADMIN				 = "Admin"
    public static let DUMP				 = "Dump"
    public static let GET_PARAMETER				 = "GetParameter"
    public static let SET_PARAMETER				 = "SetParameter"
    public static let LIST_PARAMETERS				 = "ListParameters"
    public static let DELETE_ALL_RECORDS				 = "DeleteAllRecords"
    public static let RESET_DATABASE				 = "ResetDatabase"
    public static let CLEAR_CACHE				 = "ClearCache"
    public static let DUMP_CACHE				 = "DumpCache"
    public static let CHANGE_LOG_LEVEL				 = "ChangeLogLevel"
    public static let ADD_TAG				 = "AddTag"
    public static let REMOVE_TAG				 = "RemoveTag"
    public static let CLEAR_TAGGED				 = "ClearTagged"
    public static let GET_TAGGED				 = "GetTagged"
    public static let CONNECTION_CHECK				 = "ConnectionCheck"
    public static let SET_ACTIVE_CODE				 = "SetActiveCode"
    public static let CLEAR_ACTIVE_CODE				 = "ClearActiveCode"
    public static let GET_ACTIVE_CODE				 = "GetActiveCode"
    
    public static let  LEVEL                        = "level";
    public static let  GUIDCNT                      = "guidCnt";
    // Paramaters
    public static let  WITHIN                       = "within";
    public static let  NEAR                         = "near";
    public static let  QUERY                        = "query";
    public static let  MAX_DISTANCE                 = "maxDistance";
    public static let  INTERVAL                     = "interval";

    //
    //public static let  CONNECTION_CHECK             = "connectionCheck";
    //
    public static let  OK_RESPONSE                  = "+OK+";
    public static let  NULL_RESPONSE                = "+NULL+";
    public static let  BAD_RESPONSE                 = "+NO+";
    public static let  BAD_SIGNATURE                = "+BAD_SIGNATURE+";
    public static let  ACCESS_DENIED                = "+ACCESS_DENIED+";
    public static let  OPERATION_NOT_SUPPORTED      = "+OPERATIONNOTSUPPORTED+";
    public static let  QUERY_PROCESSING_ERROR       = "+QUERYPROCESSINGERROR+";
    public static let  VERIFICATION_ERROR           = "+VERIFICATIONERROR+";
    public static let  NO_ACTION_FOUND              = "+NOACTIONFOUND+";
    public static let  BAD_ACCESSOR_GUID            = "+BADACCESSORGUID+";
    public static let  BAD_GUID                     = "+BADGUID+";
    public static let  BAD_ACCOUNT                  = "+BADACCOUNT+";
    public static let  BAD_USER                     = "+BADUSER+";
    public static let  BAD_GROUP                    = "+BADGROUP+";
    public static let  BAD_FIELD                    = "+BADFIELD+";
    public static let  BAD_ALIAS                    = "+BADALIAS+";
    public static let  BAD_ACL_TYPE                 = "+BADACLTYPE+";
    public static let  FIELD_NOT_FOUND              = "+FIELDNOTFOUND+";
    public static let  DUPLICATE_USER               = "+DUPLICATEUSER+";
    public static let  DUPLICATE_GUID               = "+DUPLICATEGUID+";
    public static let  DUPLICATE_GROUP              = "+DUPLICATEGROUP+";
    public static let  DUPLICATE_FIELD              = "+DUPLICATEFIELD+";
    public static let  DUPLICATE_NAME               = "+DUPLICATENAME+";
    public static let  JSON_PARSE_ERROR             = "+JSONPARSEERROR+";
    public static let  TOO_MANY_ALIASES             = "+TOMANYALIASES+";
    public static let  TOO_MANY_GUIDS               = "+TOMANYGUIDS+";
    public static let  UPDATE_ERROR                 = "+UPDATEERROR+";
    public static let  UPDATE_TIMEOUT               = "+UPDATETIMEOUT+";
    public static let  SELECTERROR                  = "+SELECTERROR+";
    public static let  GENERIC_ERROR                = "+GENERICERROR+";
    public static let  TIMEOUT                      = "+TIMEOUT+";
    public static let  FAIL_ACTIVE_NAMESERVER       = "+FAIL_ACTIVE+";
    public static let  INVALID_ACTIVE_NAMESERVER    = "+INVALID_ACTIVE+";
    public static let  ALL_FIELDS                   = "+ALL+";
    public static let  ALL_USERS                    = "+ALL+";
    public static let  EVERYONE                     = "+ALL+";
    //
    public static let  RSA_ALGORITHM                = "RSA";
    public static let  SIGNATURE_ALGORITHM          = "SHA1withRSA";
    //
    public static let  NAME                         = "name";
    public static let  NAMES                        = "names";
    public static let  GUID                         = "guid";
    public static let  GUID_2                       = "guid2";
    public static let  ACCOUNT_GUID                 = "accountGuid";
    public static let  READER                       = "reader";
    public static let  WRITER                       = "writer";
    public static let  ACCESSER                     = "accesser";
    public static let  FIELD                        = "field";
    public static let  FIELDS                       = "fields";
    public static let  VALUE                        = "value";
    public static let  OLD_VALUE                    = "oldvalue";
    public static let  USER_JSON                    = "userjson";
    public static let  ARGUMENT                     = "argument";
    public static let  N                            = "n";
    public static let  N2                           = "n2";
    public static let  MEMBER                       = "member";
    public static let  MEMBERS                      = "members";
    public static let  ACL_TYPE                     = "aclType";
    public static let  PUBLIC_KEY                   = "publickey";
    public static let  PASSWORD                     = "password";
    public static let  CODE                         = "code";
    public static let  SIGNATURE                    = "signature";
    public static let  PASSKEY                      = "passkey";
    public static let  SIGNATUREFULLMESSAGE         = "_signatureFullMessage_";
    // Special fields for ACL
    public static let  GUID_ACL                     = "+GUID_ACL+";
    public static let  GROUP_ACL                    = "+GROUP_ACL+";
    // Field names in guid record JSON Object
    public static let  GUID_RECORD_PUBLICKEY        = "publickey";
    public static let  GUID_RECORD_NAME             = "name";
    public static let  GUID_RECORD_GUID             = "guid";
    public static let  GUID_RECORD_TYPE             = "type";
    public static let  GUID_RECORD_CREATED          = "created";
    public static let  GUID_RECORD_UPDATED          = "updated";
    public static let  GUID_RECORD_TAGS             = "tags";
    // Field names in account record JSON Object
    public static let   ACCOUNT_RECORD_USERNAME     = "username";
    public static let   ACCOUNT_RECORD_GUID         = "guid";
    public static let   ACCOUNT_RECORD_TYPE         = "type";
    public static let   ACCOUNT_RECORD_ALIASES      = "aliases";
    public static let   ACCOUNT_RECORD_GUIDS        = "guids";
    public static let   ACCOUNT_RECORD_CREATED      = "created";
    public static let   ACCOUNT_RECORD_UPDATED      = "updated";
    public static let   ACCOUNT_RECORD_PASSWORD     = "password";
    public static let   ACCOUNT_RECORD_VERIFIED     = "verified";
    public static let   ACCOUNT_RECORD_CODE         = "code";
    // Blessed field names
    public static let  LOCATION_FIELD_NAME          = "geoLocation";
    public static let  IPADDRESS_FIELD_NAME         = "netAddress";
    // This one is special, used for the action part of the command
    public static let  COMMANDNAME                  = "COMMANDNAME"; // aka "action"
    
    // Active code actions and fields
    public static let  AC_ACTION                    = "acAction";
    public static let  AC_CODE                      = "acCode";
    // Admin Commands
    public static let PING_VALUE                    = "pingValue";
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
