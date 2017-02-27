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
import ObjectMapper
import CoreLocation

enum PostError: Error, Equatable {
    case tooManyChars
    case invalidLifetime
    case notSamePost
}

enum PostType: Int {
    case TextPost = 0
    case ImagePost = 1
}

func ==(lhs: PostError, rhs: PostError) -> Bool {
    switch (lhs, rhs) {
        case (.tooManyChars, .tooManyChars):
            return true
        case (.invalidLifetime, .invalidLifetime):
            return true
        case (.notSamePost, .notSamePost):
            return true
        case _:
            return false
    }
}

enum VisType {
    case Public
    case Private
}

let defaultLifetime = 24

class Post : Mappable {
    
    //MARK: Properties
    
    private var ID: Int? // The post's unique postID
    private var location: CLLocation?
    private var poster: User?
    
    // The text and image associated with this post
    private var postType: PostType = .TextPost
    private var text: String = ""
    private var image: UIImage?
    
    // Other properties...
    private var rating: Int = 0
    private var timeAdded: Date?
    
    // User-specific properties STATUS: waiting for brach merges
    private var vote: VoteType = .noVote
    private var includeTag: Bool = false
    
    private var visibilityType: VisType = .Public
    private var lifetime: Int = defaultLifetime
    
    private var reported: Bool = false
    
    //MARK: Initialization
    
    init?(ID: Int? = nil, location: CLLocation? = nil,
          poster: User? = nil,
          text: String = "", image: UIImage? = nil,
          timeAdded: Date? = nil, includeTag: Bool = false,
          visibilityType: VisType = .Public, lifetime: Int = defaultLifetime,
          vote: VoteType = .noVote, postType: PostType = .TextPost){
        
        // Initialize all the things!
        self.ID = ID
        self.postType = postType
        self.location = location
        self.poster = poster
        
        self.image = image
        self.timeAdded = timeAdded
        self.includeTag = includeTag
        self.visibilityType = visibilityType
        self.vote = vote
        
        // We still need to check the above values
        do{
            try setText(text)
            try setLifetime(lifetime)
        } catch PostError.tooManyChars {
            print("PostInit ERROR: too many characters!")
            return nil
        } catch PostError.invalidLifetime {
            print("PostInit ERROR: invalid lifetime!")
            return nil
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    //MARK: Object Mapping
    
    required init?(map: Map) {
        // ID is required
        if map.JSON["postid"] == nil {
            return nil
        }
        // Location is required
        if map.JSON["location"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        ID        <- map["postid"]
        postType  <- (map["type"], TransformOf<PostType, Int>(fromJSON: { (value: Int?) -> PostType? in
            if let int = value {
                return PostType(rawValue: int)
            } else {
                return nil
            }
        }, toJSON: { (value: PostType?) -> Int? in
            return value?.rawValue
        }))
        text      <- map["text"]
        location  <- (map["location"], LocationTransform())
        timeAdded <- (map["created_at"], DateTransform())
        rating    <- map["num_votes"]
        vote      <- (map["current_user_vote"], VoteTransform())
        poster    <- (map["poster"], UserTransform())
    }
    
    //MARK: Getters
    public func getID()->Int?{
        return ID
    }
    
    public func getPostType()->PostType{
        return postType
    }
    
    public func getText()->String{
        return text
    }
    
    public func getPoster() -> User? {
        return poster
    }
    
    public func getImage() -> UIImage?{
        return image
    }
    
    public func getRating()->Int{
        return rating
    }
    
    public func getTimeAdded()->Date?{
        return timeAdded
    }
    
    public func getLocation()->CLLocation?{
        return location
    }
    
    public func getVisType()->VisType{
        return visibilityType
    }
    
    public func getLifetime()->Int{
        return lifetime
    }
    
    public func getReported()->Bool{
        return reported
    }
    
    public func getVote() -> VoteType {
        return vote
    }

    
    //MARK: Setters
    
    public func setText(_ text:String) throws {
        if( text.characters.count > 200){
            throw PostError.tooManyChars
        } else {
            self.text = text
        }
    }
    
    public func setVote(_ vote: VoteType) {
        self.vote = vote
    }
    
    public func setPostType(_ type:PostType) {
        self.postType = type
    }
    
    public func setImage(_ image: UIImage){
        self.image = image
    }
    
    public func setRating(_ rating: Int){
        self.rating = rating
    }
    
    public func setTimeAdded(_ time:Date){
        self.timeAdded = time
    }
    
    public func setLocation(_ location: CLLocation){
        self.location = location
    }
    
    public func setVisType(_ visType: VisType) {
        self.visibilityType = visType
    }
    
    public func setLifetime(_ lifetime: Int) throws {
        if( lifetime < 0){
            throw PostError.invalidLifetime
        } else {
            self.lifetime = lifetime
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
        setRating(upRating)
        self.setVote(.upVote)
    }
    
    public func noVote() {
        let prevVote = self.getVote()
        var rating = self.getRating()
        switch prevVote {
        case .upVote:
            rating -= 1
        case .downVote:
            rating += 1
        case .noVote:
            return
        }
        self.setRating(rating)
        self.setVote(.noVote)
    }
    
    // Function to downvote a post -- this time decrementing the 'rating' field
    public func downVote(){
        var dnRating = self.getRating()
        dnRating -= 1
        setRating(dnRating)
        self.setVote(.downVote)
    }
    
    public func update(post: Post?) throws {
        if (post?.getID() != self.getID()) {
            throw PostError.notSamePost
        }
        
        if let text = post?.getText() {
            try self.setText(text)
        }
        if let location = post?.getLocation() {
            self.setLocation(location)
        }
        if let timeAdded = post?.getTimeAdded() {
            self.setTimeAdded(timeAdded)
        }
        if let rating = post?.getRating() {
            self.setRating(rating)
        }
        if let vote = post?.getVote() {
            self.setVote(vote)
        }
        if
            let poster = self.poster,
            let newPoster = post?.getPoster()
        {
            try poster.update(newPoster)
        } else {
            self.poster = post?.getPoster()
        }
    }
}
