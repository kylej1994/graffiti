//
//  User.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/7/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class User {
    
    //MARK: Properties
    
    // The user's attributes
    var username: String
    var name: String
    var email: String
    var userImage: UIImage?
    var textTag: String?
    var imageTag: UIImage?
   
    
    //MARK: Initialization
    
    init(username: String, name: String, email: String, userImage: UIImage?, textTag: String?, imageTag: UIImage?){
        self.username = username
        self.name = name
        self.email = email
        
        if(userImage != nil){
            self.userImage = userImage!
        }
        if(textTag != nil){
            self.textTag = textTag
        }
        if(imageTag != nil){
            self.imageTag = imageTag
        }

    }
    
}
