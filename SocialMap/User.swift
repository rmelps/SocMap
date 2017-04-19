//
//  User.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    
    init(userData:FIRUser) {
        uid = userData.uid
        
        if let mail = userData.providerData.first?.email {
            email = mail
        } else {
            email = ""
        }
    }
    
    init(uid:String, email:String) {
        self.uid = uid
        self.email = email
    }
}
