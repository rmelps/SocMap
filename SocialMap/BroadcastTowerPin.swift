//
//  BroadcastTowerPin.swift
//  SocialMap
//
//  Created by Richard Melpignano on 5/13/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import MapKit

class BroadcastTowerPin: MKPointAnnotation {
    var pinCustomImageName: String!
    var photoPath: String!
    var postedBy: String!
    var postTime: String!
    var likes: Int!
    var flags: Int!
    var descriptionText: String!
    var sourceRef: Int!
}
