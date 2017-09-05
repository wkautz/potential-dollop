//
//  auditheader.swift
//  Gemini
//
//  Created by Jordan Rosen-Kaplan on 8/22/17.
//  Copyright © 2017 Jordan Rosen-Kaplan. All rights reserved.
//  A class that represents an individual audit process

import Foundation
import UIKit
import Parse

class Audit {
    
    var outputs = Dictionary<String, String>()
    var audit_name = ""
    var filename = ""
    var room_names = Array<String>()
    var audit_entry: PFObject?
    
    /*
     
     Function: init
     --------------------------------
     Initializes an Audit object and sets audit_name
     and filename according to the parameter.
     
     */
    init(audit_name_param: String) {
        
        audit_name = audit_name_param
        
        filename = "data/" + audit_name + ".txt"
        
    }
    
    /*
     
     Function: set_name
     --------------------------------
     THIS FUNCTION MUST BE CALLED 
     (BECAUSE WE ARE USING SINGLETONS THAT
     ARE INSTANTIATED BEFORE THEY HAVE A NAME).
     
     Resets audit_name and filename according to the
     parameter.
     
     */
    func set_name(audit_name_param: String) {
        
        audit_name = audit_name_param
        
        filename = "data/" + audit_name + ".txt"
        
    }
    
    /*
     
     Function: retrieve_data
     --------------------------------
     Queries the server for an entry that 
     matches the audit_name variable, and if found, 
     sets outputs equal to the rehydrated version.
     
     */
    func retrieve_data() {
        
        let query = PFQuery(className: "Audits")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                for object in objects! {
                    
                    if object["name"] as! String != self.audit_name {
                        
                        continue
                        
                    } else {
                        
                        self.outputs = self.rehydrateOutputs(outputFileString: object["outputs"] as! String)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    /*
     
     Function: save_data
     --------------------------------
     Saves outputs to the server 
     AND CLEARS ALL VALUES
     
     */
    func save_data() {
        
        let auditObject = PFObject(className: "Audits")
        
        auditObject["name"] = String(audit_name)
        auditObject["outputs"] = String(outputs.description)
        
        auditObject.saveInBackground { (success, error) in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                print("Saved")
                
            }
            
        }
        
        //Clears values!
        
        outputs = Dictionary<String, String>()
        audit_name = ""
        filename = ""
        room_names = Array<String>()
        
    }
    
    /*
     
     Function: add_room
     --------------------------------
     Adds a room to the list of all rooms
     for the audit
     
     */
    func add_room(name: String) {
        
        room_names.append(name)
        
    }
    
    /*
     
     Function: rehydrateOutputs
     --------------------------------
     Takes in a String that is a .description
     output of a Dictionary<String, String> and formats
     its elements in the same key value pairs as when it 
     started
     
     */
    private func rehydrateOutputs(outputFileString: String) -> Dictionary<String, String> {
        
        let array = outputFileString.components(separatedBy: ", ")
        
        var iterator = 0
        var new_dict = Dictionary<String, String>()
        
        for entry in array {
            
            var key_index_start = entry.index(entry.startIndex, offsetBy: 1)
            
            if iterator == 0 {
                
                key_index_start = entry.index(entry.startIndex, offsetBy: 2)
                
            }
            
            let key1 = entry.substring(from: key_index_start)
            
            let key_index_end = key1.characters.index(of: "\"")!
            
            let key2 = key1.substring(to: key_index_end)
            
            let value_index = entry.characters.index(of: ":")!
            
            let value_index_start = entry.index(value_index, offsetBy: 3)
            
            let value1 = entry.substring(from: value_index_start)
            
            let value_index_end = value1.characters.index(of: "\"")!
            
            let value2 = value1.substring(to: value_index_end)
            
            iterator += 1
            
            new_dict[key2] = value2
        }
        
        return new_dict
        
    }
    
}
