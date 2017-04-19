//
//  Location.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Location {
    let key: String!
    let content: String!
    let addedByUser: String!
    let itemRef: FIRDatabaseReference?
    
    init(content: String, addedByUser: String, key:String = "") {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
    }
    
    init(snapShot: FIRDataSnapshot) {
        key = snapShot.key
        itemRef = snapShot.ref
        
        let snapShotValue = snapShot.value! as! [String: AnyObject]
        
        if let locationContent = snapShotValue["content"] as? String {
            content = locationContent
        } else {
            content = ""
        }
        
        if let locationUser = snapShotValue["addedByUser"] as? String {
            addedByUser = locationUser
        } else {
            addedByUser = ""
        }
    }
}
