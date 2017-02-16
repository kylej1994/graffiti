//
//  User.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/7/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import ObjectMapper
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


class User : Mappable {
    
    //MARK: Properties
    
    // The user's attributes
    private var id: Int?
    private var username: String?
    private var name: String?
    private var email: String?
    private var userImage: UIImage?
    private var bio: String?
    private var imageTag: UIImage?
    
    //MARK: Initialization
    
    init(id: Int, username: String? = nil, name: String? = nil, email: String? = nil, userImage: UIImage? = nil, bio: String? = nil, imageTag: UIImage? = nil){
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.userImage = userImage
        self.bio = bio
        self.imageTag = imageTag
    }
    
    //MARK: Object Mapping
    
    required init?(map: Map) {
        // ID is required
        if map.JSON["userid"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id       <- map["userid"]
        username <- map["username"]
        name     <- map["name"]
        email    <- map["email"]
        bio  <- map["bio"]
    }
    
    //MARK: Getters
    
    public func getId()->Int{
        return id!
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
    
    public func getBio() -> String?{
        return bio
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
    
    public func setBio(_ bio: String){
        self.bio = bio
    }
}
