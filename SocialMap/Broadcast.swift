//
//  Broadcast.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct Broadcast {
    let key: String!
    let content: String!
    let addedByUser: String!
    let itemRef: FIRDatabaseReference?
    /*
    let photo: UIPhoto?
 */
    
    init(content: String, addedByUser: String, /*photo: UIPhoto, */ key:String = "") {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
        /*
        self.photo = photo
 */
    }
    
    init(snapShot: FIRDataSnapshot) {
        key = snapShot.key
        itemRef = snapShot.ref
        
        let snapShotValue = snapShot.value! as! [String: AnyObject]
        
        if let broadcastContent = snapShotValue["content"] as? String {
            content = broadcastContent
        } else {
            content = ""
        }
        
        if let broadcastUser = snapShotValue["addedByUser"] as? String {
            addedByUser = broadcastUser
        } else {
            addedByUser = ""
        }
        /*
        if let broadcastPhoto = snapShotValue["photo"] as? UIPhoto {
            photo = broadcastPhoto
        } else {
            photo = nil
        }
 */
    }
}
