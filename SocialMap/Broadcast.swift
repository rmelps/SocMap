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
    let photoPath: String!
    let uploadTime: [String:String]
    let coordinate: [String:String]
    let likes: [String:Int]
    let flags: [String:Int]
    
    init(content: String, addedByUser: String, photoPath: String, key:String = "", time: [String:String], coordinate: [String:String]) {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
        self.photoPath = photoPath
        self.uploadTime = time
        self.coordinate = coordinate
        self.likes = ["likes": 0]
        self.flags = ["flags": 0]
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
        
        if let broadcastPhoto = snapShotValue["photo"] as? String {
            photoPath = broadcastPhoto
        } else {
            photoPath = ""
        }
        
        if let uploadTime = snapShotValue["time"] as? [String:String] {
            self.uploadTime = uploadTime
        } else {
            uploadTime = ["":""]
        }
        
        if let coordinate = snapShotValue["coordinate"] as? [String:String] {
            self.coordinate = coordinate
        } else {
            coordinate = ["":""]
        }
        
        if let likes = snapShotValue["likes"] as? [String:Int] {
            self.likes = likes
        } else {
            likes = ["likes":100]
        }
        
        if let flags = snapShotValue["flags"] as? [String:Int] {
            self.flags = flags
        } else {
            flags = ["flags":0]
        }
    }
    
    func toAny() -> Any {
        return [
            "content": content,
            "addedByUser": addedByUser,
            "photo": photoPath,
            "time": uploadTime,
            "coordinate": coordinate,
            "likes": likes,
            "flags": flags
            ]
    }
}
