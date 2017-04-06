//
//  GGUserClientBridge.swift
// UMassEmergenxy
//
//  Created by Görkem Güclü on 23.05.15.
//  Copyright (c) 2015 University of Massachusetts.
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

@objc class GGUserClientBridge: ClientBridge {

    private var userUDID : String
    
    override init?(host: String, port: UInt16) {

        self.userUDID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        super.init(host: host, port: port);
    }
    
    
//    override func readField(field: String, completion: (result: String?, error: String?) -> Void) {
//        
//        super.readField(self.userUDID, completion: { (result, error) -> Void in
//            
//            if(result != nil){
//                
//                
//                completion(result: result, error: error)
//            }
//        
//        })
//    }
    
//    override func writeField(field: String, value: String, completion: (result: Bool, error: String?) -> Void) {
//        
//        super.writeField(field, value: value, completion: { (success, error) -> Void in
//        
//            if(success){
//                
//            }else{
//                NSLog("Error: " + error! + "")
//            }
//
//        })
//        
//    }
    
}
