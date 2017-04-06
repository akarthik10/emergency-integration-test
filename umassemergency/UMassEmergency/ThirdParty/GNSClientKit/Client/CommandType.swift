//
//  CommandType.swift
// UMassEmergenxy
//
//  Created by David Westbrook on 12/9/16.
//  Copyright © 2016 University of Massachusetts.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you
//  may not use this file except in compliance with the License. You
//  may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
//  implied. See the License for the specific language governing
//  permissions and limitations under the License.
//

import Foundation

public struct CommandType {
    let name: String
    let number: Int
    private init(_ name:String, _ number:Int) {
        self.name = name
        self.number = number
    }
}

// make it hashable
extension CommandType: Hashable {
    public var hashValue:Int {
        return CommandType.allValues.indexOf(self)!
    }
}

// make equals work
public func ==(lhs:CommandType, rhs:CommandType) -> Bool {
    return lhs.name == rhs.name && lhs.number == rhs.number
}

// This is generated from the java code.. do not edit.
extension CommandType {
    static let Append = CommandType("Append", 110)
    static let AppendList = CommandType("AppendList", 111)
    static let AppendListUnsigned = CommandType("AppendListUnsigned", 113)
    static let AppendListWithDuplication = CommandType("AppendListWithDuplication", 114)
    static let AppendListWithDuplicationUnsigned = CommandType("AppendListWithDuplicationUnsigned", 116)
    static let AppendOrCreate = CommandType("AppendOrCreate", 120)
    static let AppendOrCreateList = CommandType("AppendOrCreateList", 121)
    static let AppendOrCreateListUnsigned = CommandType("AppendOrCreateListUnsigned", 123)
    static let AppendOrCreateUnsigned = CommandType("AppendOrCreateUnsigned", 125)
    static let AppendUnsigned = CommandType("AppendUnsigned", 131)
    static let AppendWithDuplication = CommandType("AppendWithDuplication", 132)
    static let AppendWithDuplicationUnsigned = CommandType("AppendWithDuplicationUnsigned", 134)
    static let Clear = CommandType("Clear", 140)
    static let ClearUnsigned = CommandType("ClearUnsigned", 142)
    static let Create = CommandType("Create", 150)
    static let CreateEmpty = CommandType("CreateEmpty", 151)
    static let CreateList = CommandType("CreateList", 153)
    static let Read = CommandType("Read", 160)
    static let ReadUnsigned = CommandType("ReadUnsigned", 162)
    static let ReadMultiField = CommandType("ReadMultiField", 163)
    static let ReadMultiFieldUnsigned = CommandType("ReadMultiFieldUnsigned", 164)
    static let ReadArray = CommandType("ReadArray", 170)
    static let ReadArrayOne = CommandType("ReadArrayOne", 171)
    static let ReadArrayOneUnsigned = CommandType("ReadArrayOneUnsigned", 173)
    static let ReadArrayUnsigned = CommandType("ReadArrayUnsigned", 175)
    static let Remove = CommandType("Remove", 180)
    static let RemoveList = CommandType("RemoveList", 181)
    static let RemoveListUnsigned = CommandType("RemoveListUnsigned", 183)
    static let RemoveUnsigned = CommandType("RemoveUnsigned", 185)
    static let Replace = CommandType("Replace", 190)
    static let ReplaceList = CommandType("ReplaceList", 191)
    static let ReplaceListUnsigned = CommandType("ReplaceListUnsigned", 193)
    static let ReplaceOrCreate = CommandType("ReplaceOrCreate", 210)
    static let ReplaceOrCreateList = CommandType("ReplaceOrCreateList", 211)
    static let ReplaceOrCreateListUnsigned = CommandType("ReplaceOrCreateListUnsigned", 213)
    static let ReplaceOrCreateUnsigned = CommandType("ReplaceOrCreateUnsigned", 215)
    static let ReplaceUnsigned = CommandType("ReplaceUnsigned", 217)
    static let ReplaceUserJSON = CommandType("ReplaceUserJSON", 220)
    static let ReplaceUserJSONUnsigned = CommandType("ReplaceUserJSONUnsigned", 221)
    static let CreateIndex = CommandType("CreateIndex", 230)
    static let Substitute = CommandType("Substitute", 231)
    static let SubstituteList = CommandType("SubstituteList", 232)
    static let SubstituteListUnsigned = CommandType("SubstituteListUnsigned", 234)
    static let SubstituteUnsigned = CommandType("SubstituteUnsigned", 236)
    static let RemoveField = CommandType("RemoveField", 240)
    static let RemoveFieldUnsigned = CommandType("RemoveFieldUnsigned", 242)
    static let Set = CommandType("Set", 250)
    static let SetFieldNull = CommandType("SetFieldNull", 252)
    static let Select = CommandType("Select", 310)
    static let SelectNear = CommandType("SelectNear", 320)
    static let SelectWithin = CommandType("SelectWithin", 321)
    static let SelectQuery = CommandType("SelectQuery", 322)
    static let SelectGroupLookupQuery = CommandType("SelectGroupLookupQuery", 311)
    static let SelectGroupSetupQuery = CommandType("SelectGroupSetupQuery", 312)
    static let SelectGroupSetupQueryWithGuid = CommandType("SelectGroupSetupQueryWithGuid", 313)
    static let SelectGroupSetupQueryWithGuidAndInterval = CommandType("SelectGroupSetupQueryWithGuidAndInterval", 314)
    static let SelectGroupSetupQueryWithInterval = CommandType("SelectGroupSetupQueryWithInterval", 315)
    static let AddAlias = CommandType("AddAlias", 410)
    static let AddGuid = CommandType("AddGuid", 411)
    static let AddMultipleGuids = CommandType("AddMultipleGuids", 412)
    static let AddMultipleGuidsFast = CommandType("AddMultipleGuidsFast", 413)
    static let AddMultipleGuidsFastRandom = CommandType("AddMultipleGuidsFastRandom", 414)
    static let LookupAccountRecord = CommandType("LookupAccountRecord", 420)
    static let LookupRandomGuids = CommandType("LookupRandomGuids", 421)
    static let LookupGuid = CommandType("LookupGuid", 422)
    static let LookupPrimaryGuid = CommandType("LookupPrimaryGuid", 423)
    static let LookupGuidRecord = CommandType("LookupGuidRecord", 424)
    static let RegisterAccount = CommandType("RegisterAccount", 430)
    static let RegisterAccountSecured = CommandType("RegisterAccountSecured", 431)
    static let RegisterAccountUnsigned = CommandType("RegisterAccountUnsigned", 432)
    static let RemoveAccount = CommandType("RemoveAccount", 440)
    static let RemoveAlias = CommandType("RemoveAlias", 441)
    static let RemoveGuid = CommandType("RemoveGuid", 442)
    static let RemoveGuidNoAccount = CommandType("RemoveGuidNoAccount", 443)
    static let RetrieveAliases = CommandType("RetrieveAliases", 444)
    static let RemoveAccountWithPassword = CommandType("RemoveAccountWithPassword", 445)
    static let SetPassword = CommandType("SetPassword", 450)
    static let VerifyAccount = CommandType("VerifyAccount", 451)
    static let ResendAuthenticationEmail = CommandType("ResendAuthenticationEmail", 452)
    static let ResetKey = CommandType("ResetKey", 460)
    static let AclAdd = CommandType("AclAdd", 510)
    static let AclAddSelf = CommandType("AclAddSelf", 511)
    static let AclRemove = CommandType("AclRemove", 512)
    static let AclRemoveSelf = CommandType("AclRemoveSelf", 513)
    static let AclRetrieve = CommandType("AclRetrieve", 514)
    static let AclRetrieveSelf = CommandType("AclRetrieveSelf", 515)
    static let FieldCreateAcl = CommandType("FieldCreateAcl", 516)
    static let FieldDeleteAcl = CommandType("FieldDeleteAcl", 517)
    static let FieldAclExists = CommandType("FieldAclExists", 518)
    static let AddMembersToGroup = CommandType("AddMembersToGroup", 610)
    static let AddMembersToGroupSelf = CommandType("AddMembersToGroupSelf", 611)
    static let AddToGroup = CommandType("AddToGroup", 612)
    static let AddToGroupSelf = CommandType("AddToGroupSelf", 613)
    static let GetGroupMembers = CommandType("GetGroupMembers", 614)
    static let GetGroupMembersSelf = CommandType("GetGroupMembersSelf", 615)
    static let GetGroups = CommandType("GetGroups", 616)
    static let GetGroupsSelf = CommandType("GetGroupsSelf", 617)
    static let RemoveFromGroup = CommandType("RemoveFromGroup", 620)
    static let RemoveFromGroupSelf = CommandType("RemoveFromGroupSelf", 621)
    static let RemoveMembersFromGroup = CommandType("RemoveMembersFromGroup", 622)
    static let RemoveMembersFromGroupSelf = CommandType("RemoveMembersFromGroupSelf", 623)
    static let Help = CommandType("Help", 710)
    static let HelpTcp = CommandType("HelpTcp", 711)
    static let HelpTcpWiki = CommandType("HelpTcpWiki", 712)
    static let Dump = CommandType("Dump", 716)
    static let ConnectionCheck = CommandType("ConnectionCheck", 737)
    static let SetCode = CommandType("SetCode", 810)
    static let ClearCode = CommandType("ClearCode", 811)
    static let GetCode = CommandType("GetCode", 812)
    static let Unknown = CommandType("Unknown", 999)
    static let allValues = [Append, AppendList, AppendListUnsigned, AppendListWithDuplication, AppendListWithDuplicationUnsigned, AppendOrCreate, AppendOrCreateList, AppendOrCreateListUnsigned, AppendOrCreateUnsigned, AppendUnsigned, AppendWithDuplication, AppendWithDuplicationUnsigned, Clear, ClearUnsigned, Create, CreateEmpty, CreateList, Read, ReadUnsigned, ReadMultiField, ReadMultiFieldUnsigned, ReadArray, ReadArrayOne, ReadArrayOneUnsigned, ReadArrayUnsigned, Remove, RemoveList, RemoveListUnsigned, RemoveUnsigned, Replace, ReplaceList, ReplaceListUnsigned, ReplaceOrCreate, ReplaceOrCreateList, ReplaceOrCreateListUnsigned, ReplaceOrCreateUnsigned, ReplaceUnsigned, ReplaceUserJSON, ReplaceUserJSONUnsigned, CreateIndex, Substitute, SubstituteList, SubstituteListUnsigned, SubstituteUnsigned, RemoveField, RemoveFieldUnsigned, Set, SetFieldNull, Select, SelectNear, SelectWithin, SelectQuery, SelectGroupLookupQuery, SelectGroupSetupQuery, SelectGroupSetupQueryWithGuid, SelectGroupSetupQueryWithGuidAndInterval, SelectGroupSetupQueryWithInterval, AddAlias, AddGuid, AddMultipleGuids, AddMultipleGuidsFast, AddMultipleGuidsFastRandom, LookupAccountRecord, LookupRandomGuids, LookupGuid, LookupPrimaryGuid, LookupGuidRecord, RegisterAccount, RegisterAccountSecured, RegisterAccountUnsigned, RemoveAccount, RemoveAlias, RemoveGuid, RemoveGuidNoAccount, RetrieveAliases, RemoveAccountWithPassword, SetPassword, VerifyAccount, ResendAuthenticationEmail, ResetKey, AclAdd, AclAddSelf, AclRemove, AclRemoveSelf, AclRetrieve, AclRetrieveSelf, FieldCreateAcl, FieldDeleteAcl, FieldAclExists, AddMembersToGroup, AddMembersToGroupSelf, AddToGroup, AddToGroupSelf, GetGroupMembers, GetGroupMembersSelf, GetGroups, GetGroupsSelf, RemoveFromGroup, RemoveFromGroupSelf, RemoveMembersFromGroup, RemoveMembersFromGroupSelf, Help, HelpTcp, HelpTcpWiki, Dump, ConnectionCheck, SetCode, ClearCode, GetCode, Unknown]
}

