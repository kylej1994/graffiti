//
//  User.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/7/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit

enum UserError: Error, Equatable {
    case noImage
    case noTextTag
    case noImageTag
    case tooManyChars
}

func ==(lhs: UserError, rhs: UserError) -> Bool {
    switch (lhs, rhs) {
    case (.noImage, .noImage):
        return true
    case (.noTextTag, .noTextTag):
        return true
    case (.noImageTag, .noImageTag):
        return true
    case (.tooManyChars, .tooManyChars):
        return true
    case _:
        return false
    }
}


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
    
    //MARK: Getters
    
    public func getUsername()->String{
        return username
    }
    
    public func getName()->String{
        return name
    }
    
    public func getEmail()->String{
        return email
    }
    
    public func getUserImage() throws -> UIImage{
        // Try to retrieve the image of this post
        guard let ret: UIImage = userImage else {
            
            // Throw an error if it's nil
            throw UserError.noImage
        }
        return ret
    }
    
    public func getTextTag() throws -> String{
        // Try to retrieve the image of this post
        guard let ret: String = textTag else {
            
            // Throw an error if it's nil
            throw UserError.noTextTag
        }
        return ret
    }
    
    public func getImageTag() throws -> UIImage{
        // Try to retrieve the image of this post
        guard let ret: UIImage = imageTag else {
            
            // Throw an error if it's nil
            throw UserError.noImageTag
        }
        return ret
    }
    
    //MARK: Setters
    
    public func setUsername(_username:String) throws {
        if( _username.characters.count > 100){
            throw UserError.tooManyChars
        } else {
            self.username = _username
        }
    }
    
    public func setName(_name:String) {
        self.name = _name
    }
    
    public func setEmail(_email:String) {
        self.username = _email
    }
    
    public func setUserImage(_UImage: UIImage){
        self.userImage = _UImage
    }
    
    public func setTagImage(_TImage: UIImage){
        self.imageTag = _TImage
    }
    
    public func setImage(_textTag: String){
        self.textTag = _textTag
    }
}
