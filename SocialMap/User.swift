//
//  User.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct User {
    let uid: String
    var email: String
    var userName: String
    let itemRef: FIRDatabaseReference?
    
    init(userData:FIRUser, snapShot:FIRDataSnapshot) {
        uid = userData.uid
        
        itemRef = snapShot.ref
        
        let snapShotValue = snapShot.value as? [String: AnyObject]
        
        if let mail = userData.providerData.first?.email {
            email = mail
        } else {
            email = ""
        }
        if let name = snapShotValue?["userName"] as? [String: AnyObject] {
            if let subName = name["userName"] as? String{
                userName = subName
            } else {
                userName = "no name"
            }
        } else {
            userName = "no name"
        }
    }

    init(uid:String, email:String, userName: String) {
        self.uid = uid
        self.email = email
        self.userName = userName
        self.itemRef = nil
    }
    
    func toAny() -> Any {
        return ["uid":uid, "email":email, "userName":["userName": userName]]
    }
}
