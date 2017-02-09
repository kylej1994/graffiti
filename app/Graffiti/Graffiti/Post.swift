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

enum PostError: Error {
    case noImage
    case tooManyChars
    case invalidLifetime
    case invalidVisibility
}

enum VisType: Int{
    case Public = 1
    case Private = 2
}

class Post {
    
    //MARK: Properties
    
    // The post's unique postID
    private var ID: Int
    
    // The text and image associated with this post
    private var text: String
    private var image: UIImage?
    
    // Other properties...
    private var rating: Int
    private var timeAdded: NSDate
    private var location: CLLocation
    
    // User-specific properties STATUS: waiting for brach merges
    //private var user: User
    private var includeTag: Bool
    
    private var visibilityType: Int
    private var lifetime: Int
    
    private var reported: Bool
    
    //MARK: Initialization
    
    init?(ID: Int, text: String, image: UIImage?, timeAdded: NSDate,
          location: CLLocation, /*user: User,*/ includeTag: Bool,
          visibilityType: Int, lifetime: Int){
        
        // Initialize all the things!
        self.ID = ID
        self.text = text
        
        // Make certain we've got an actual image
        if image != nil {
            self.image = image!
        }
        
        self.rating = 0
        self.timeAdded = timeAdded
        self.location = location
        
        //self.user = user
        self.includeTag = includeTag
        
        self.visibilityType = VisType.Public.rawValue
        self.lifetime = lifetime
        
        self.reported = false
        
        // We still need to check the above values
        do{
            try setText(_text: text)
            try setLifetime(_lifetime: lifetime)
            try setVisType(_visType: visibilityType)
        } catch PostError.tooManyChars {
            print("PostInit ERROR: too many characters!")
            return nil
        } catch PostError.invalidLifetime {
            print("PostInit ERROR: invalid lifetime!")
            return nil
        } catch PostError.invalidVisibility {
            print("PostInit ERROR: invalid visibility!")
            return nil
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    //MARK: Getters
    public func getID()->Int{
        return ID
    }
    
    public func getText()->String{
        return text
    }
    
    public func getImage() throws -> UIImage{
        // Try to retrieve the image of this post
        guard let ret: UIImage = image else {
            
            // Throw an error if it's nil
            throw PostError.noImage
        }
        return ret
    }
    
    public func getRating()->Int{
        return rating
    }
    
    public func getTimeAdded()->NSDate{
        return timeAdded
    }
    
    public func getLocation()->CLLocation{
        return location
    }
    
    public func getVisType()->Int{
        return visibilityType
    }
    
    public func getLifetime()->Int{
        return lifetime
    }
    
    //MARK: Setters
    
    public func setText(_text:String) throws {
        if( _text.characters.count > 200){
            throw PostError.tooManyChars
        } else {
            self.text = _text
        }
    }
    
    public func setImage(_image: UIImage){
        self.image = _image
    }
    
    public func setRating(_rating: Int){
        self.rating = _rating
    }
    
    public func setTimeAdded(_time:NSDate){
        self.timeAdded = _time
    }
    
    public func setLocation(_location: CLLocation){
        self.location = _location
    }
    
    public func setVisType(_visType: Int) throws {
        if( _visType != 1 || _visType != 2){
            throw PostError.invalidVisibility
        } else {
            self.visibilityType = _visType
        }
    }
    
    public func setLifetime(_lifetime: Int) throws {
        if( _lifetime < 0){
            throw PostError.invalidLifetime
        } else {
            self.lifetime = _lifetime
        }
    }
    
    public func setReported(){
        self.reported = true
    }
    
    //MARK: Other Functions
    
    // Function to report a post -- changes this post's boolean 'report' flag to true
    public func report(){
        setReported()
    }
    
    // Function to upvote a post -- literally just increments the 'rating' field
    public func upVote(){
        var upRating = self.getRating()
        upRating += 1
        setRating(_rating: upRating)
    }
    
    // Function to downvote a post -- this time decrementing the 'rating' field
    public func downVote(){
        var dnRating = self.getRating()
        dnRating -= 1
        setRating(_rating: dnRating)
    }
}
