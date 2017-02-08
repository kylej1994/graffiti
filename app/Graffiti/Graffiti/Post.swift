//
//  Post.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/7/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class Post {
    
    //MARK: Properties
    
    // The post's unique postID
    var ID: Int
    
    // The text and image associated with this post
    var text: String
    var image: UIImage?
    
    // Other properties...
    var rating: Int
    var timeAdded: NSDate
    var location: CLLocation
    
    // User-specific properties that I'll, you know, add once I actually make the User model...
    //var user: User
    var includeTag: Bool
    
    var visibilityType: Int
    var lifetime: Int
    
    //MARK: Initialization
    
    init(ID: Int, text: String, image: UIImage?, rating: Int, timeAdded: NSDate, location: CLLocation, /*user: User,*/
        includeTag: Bool, visibilityType: Int, lifetime: Int){
        
        // Initialize all the things!
        self.ID = ID
        self.text = text
        
        // Make certain we've got an actual image
        if image != nil {
            self.image = image!
        }
        
        self.rating = rating
        self.timeAdded = timeAdded
        self.location = location
        
        //self.user = user
        self.includeTag = includeTag
        
        self.visibilityType = visibilityType
        self.lifetime = lifetime
    }
    
}
