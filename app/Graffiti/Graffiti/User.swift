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
    case notSameUser
    case tooFewChars
}

func ==(lhs: UserError, rhs: UserError) -> Bool {
    switch (lhs, rhs) {
    case (.tooFewChars, .tooFewChars):
        return true
    case (.tooManyChars, .tooManyChars):
        return true
    case (.notSameUser, .notSameUser):
        return true
    default:
        return false
    }
}


class User : Mappable {
    
    //MARK: Properties
    
    // The user's attributes
    private var id: Int?
    private var username: String?
    private var name: String?
    private var email: String?
    private var phoneNumber: String?
    private var userImage: UIImage?
    private var bio: String?
    private var imageTag: UIImage?
    
    //MARK: Initialization
    
    init(id: Int, username: String? = nil, name: String? = nil, email: String? = nil, phoneNumber: String? = nil, userImage: UIImage? = nil, bio: String? = nil, imageTag: UIImage? = nil){
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
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
        id          <- map["userid"]
        username    <- map["username"]
        name        <- map["name"]
        email       <- map["email"]
        phoneNumber <- map["phone_number"]
        bio         <- map["bio"]
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
    
    public func getPhoneNumber()->String?{
        return phoneNumber
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
    
    public func setUsername(_ username: String) throws {
        if(username.characters.count > 25){
            throw UserError.tooManyChars
        } else if(username.characters.count < 3) {
            throw UserError.tooFewChars
        } else {
            self.username = username
        }
    }
    
    public func setName(_ name: String) {
        self.name = name
    }
    
    public func setEmail(_ email: String) {
        self.email = email
    }
    
    public func setPhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
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
    
    public func update(_ user: User?) throws {
        if user?.getId() != self.getId() {
            throw UserError.notSameUser
        }
        
        if let username = user?.getUsername() {
            try self.setUsername(username)
        }
        
        if let name = user?.getName() {
            self.setName(name)
        }
        
        if let email = user?.getEmail() {
            self.setEmail(email)
        }
        
        if let phoneNum = user?.getPhoneNumber() {
            self.setPhoneNumber(phoneNum)
        }
        
        if let bio = user?.getBio() {
            self.setBio(bio)
        }
    }
}
