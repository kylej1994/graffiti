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
    case tooManyChars
}

func ==(lhs: UserError, rhs: UserError) -> Bool {
    switch (lhs, rhs) {
    case (.tooManyChars, .tooManyChars):
        return true
    }
}


class User {
    
    //MARK: Properties
    
    // The user's attributes
    private var id: Int
    private var username: String?
    private var name: String?
    private var email: String?
    private var userImage: UIImage?
    private var textTag: String?
    private var imageTag: UIImage?
   
    
    //MARK: Initialization
    
    init(id: Int, username: String? = nil, name: String? = nil, email: String? = nil, userImage: UIImage? = nil, textTag: String? = nil, imageTag: UIImage? = nil){
        self.id = id
        
        self.username = username
        self.name = name
        self.email = email
        self.userImage = userImage
        self.textTag = textTag
        self.imageTag = imageTag
    }
    
    //MARK: Getters
    
    public func getId()->Int{
        return id
    }
    
    public func getUsername()->String?{
        return username
    }
    
    public func getName()->String?{
        return name
    }
    
    public func getEmail()->String?{
        return email
    }
    
    public func getUserImage() -> UIImage?{
        return userImage
    }
    
    public func getTextTag() -> String?{
        return textTag
    }
    
    public func getImageTag() -> UIImage?{
        return imageTag
    }
    
    //MARK: Setters
    
    public func setUsername(_ username:String) throws {
        if(username.characters.count > 100){
            throw UserError.tooManyChars
        } else {
            self.username = username
        }
    }
    
    public func setName(_ name:String) {
        self.name = name
    }
    
    public func setEmail(_ email:String) {
        self.username = email
    }
    
    public func setUserImage(_ UImage: UIImage){
        self.userImage = UImage
    }
    
    public func setTagImage(_ TImage: UIImage){
        self.imageTag = TImage
    }
    
    public func setImage(_ textTag: String){
        self.textTag = textTag
    }
}
