
//
//  PostTest.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest
import CoreLocation
import Foundation

// Global vars for use in tests
let dramaticBlabber: String = "According to all known laws of aviation,there is no way a bee should be able to fly.Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible.Yellow, black. Yellow, black.Yellow, black. Yellow, black. Ooh, black and yellow! Let's shake it up a little.Barry! Breakfast is ready!Coming! Hang on a second. Hello? - Barry? - Adam? - Can you believe this is happening?- I can't. I'll pick you up. Looking sharp. Use the stairs. Your father paid good money for those. Sorry. I'm excited. Here's the graduate. We're very proud of you, son. A perfect report card, all B's. Very proud.Ma! I got a thing going here. - You got lint on your fuzz. - Ow! That's me! - Wave to us! We'll be in row 118,000. - Bye! Barry, I told you,stop flying in the house! - Hey, Adam. - Hey, Barry. - Is that fuzz gel? - A little. Special day, graduation. Never thought I'd make it. Three days grade school, three days high school. Those were awkward. Three days college. I'm glad I took a day and hitchhiked around the hive. You did come back different.- Hi, Barry."

let date: Date = Date.init()
let dateTest: Date = Date.init(timeIntervalSince1970: 100100)

let latitude: Double = 41.792199
let longitude: Double = -87.599691
let secretLocation: CLLocation = CLLocation.init(latitude: latitude, longitude: longitude)

let Jlatitude: Double = 41.796673
let Jlongitude: Double = -87.605184
let SUPERsecretLocation: CLLocation = CLLocation.init(latitude: Jlatitude, longitude: Jlongitude)


class PostTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Initialaztion tests
    func testInit() {
        
        // Testing to make sure we don't allow a post to be made with a negative lifetime
        let invalidLifetimePost: Post? = Post(ID: 1, location: SUPERsecretLocation, text: "This is a failing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: -1)
        XCTAssertNil(invalidLifetimePost)
        
        // Testing to make sure we can't make a post whose text is > 200 chars
        let tooManyCharsPost: Post? = Post(ID: 1, location: secretLocation, text: dramaticBlabber, image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 7)
        XCTAssertNil(tooManyCharsPost)
        
        // A test to make sure we're capable of creating a post
        let passPost: Post = Post(ID: 1, location: secretLocation, text: "This is a passing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 7)!
        XCTAssertNotNil(passPost)
    }
    
    // Testing getter/setter methods
    func testSetText() {
        
        let passPost: Post = Post(ID: 1, location: secretLocation, text: "This is a passing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 7)!
        
        do {
            _ = try passPost.setText(dramaticBlabber)
        } catch let e as PostError {
            XCTAssertEqual(e, PostError.tooManyChars)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
    func testSetLifetime() {
        
        let passPost: Post = Post(ID: 1, location: secretLocation, text: "This is a passing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 7)!
        
        do {
            _ = try passPost.setLifetime(-1)
        } catch let e as PostError {
            XCTAssertEqual(e, PostError.invalidLifetime)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
    func testSettersTest() {
        
        let passPost: Post = Post(ID: 1, location: secretLocation, text: "This is a passing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 1)!
        
        do {
            _ = try passPost.setText("Did I actually change?")
            _ = passPost.setRating(9001)
            _ = passPost.setTimeAdded(dateTest)
            _ = passPost.setLocation(SUPERsecretLocation)
            _ = passPost.setVisType(.Private)
            _ = try passPost.setLifetime(7)
            
            XCTAssertEqual(passPost.getText(), "Did I actually change?")
            XCTAssertEqual(passPost.getRating(), 9001)
            XCTAssertEqual(passPost.getTimeAdded(), dateTest)
            XCTAssertEqual(passPost.getLocation(), SUPERsecretLocation)
            XCTAssertEqual(passPost.getVisType(), .Private)
            XCTAssertEqual(passPost.getLifetime(), 7)
            
            // ==================================================== //
            // ~~~~~~~~~~~~~~~~ Interation 4 Tests ~~~~~~~~~~~~~~~~ //
            // ==================================================== //
            
            _ = passPost.setPostType(.ImagePost)
            XCTAssertEqual(passPost.getPostType(), .ImagePost)
            
            // lol that's it
            
        } catch {
            XCTFail("Wrong Error!")
        }
    }

    func testReport() {
        let passPost: Post = Post(ID: 1, location: secretLocation, text: "This is a passing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 1)!
        
        XCTAssertFalse(passPost.getReported())
        
        passPost.report()
        
        XCTAssertTrue(passPost.getReported())
    }
    
    func testVoting() {
        let passPost: Post = Post(ID: 1, location: secretLocation, text: "This is a passing post!", image: nil, timeAdded: date, includeTag: false, visibilityType: .Public, lifetime: 1)!
        
        var i:Int = 0
        while(i < 50){
            passPost.upVote()
            i += 1
        }
        
        XCTAssertEqual(passPost.getRating(), 50)
        
        var j:Int = 0
        while(j < 25){
            passPost.downVote()
            j += 1
        }
        
        XCTAssertEqual(passPost.getRating(), 25)
    }
    
    func testToJSON() {
        let location = CLLocation(latitude: 10.0, longitude: 10.0)
        let poster = User(id: 1, username: "username", name: "First Last", email: "me@email.com", phoneNumber: "123-456-7890", bio: "This is a bio")
        let post = Post(ID: 1234, location: location, poster: poster, text: "This is a post", timeAdded: Date(timeIntervalSince1970: 1487975373), vote: VoteType.upVote, postType: PostType.TextPost)
        post?.setRating(10)
        
        let json: [String: Any] = (post?.toJSON())!
        XCTAssertEqual(json["postid"] as? Int, 1234)
        XCTAssertEqual(json["text"] as? String, "This is a post")
        XCTAssertEqual(json["created_at"] as? Double, 1487975373)
        XCTAssertEqual(json["num_votes"] as? Int, 10)
        XCTAssertEqual(json["current_user_vote"] as? Int, 1)
        
        let locJson: [String: Any] = json["location"] as! [String: Any]
        XCTAssertEqual(locJson["longitude"] as? Double, 10.0)
        XCTAssertEqual(locJson["latitude"] as? Double, 10.0)
        
        let userJson: [String: Any] = json["poster"] as! [String: Any]
        XCTAssertEqual(userJson["userid"] as? Int, 1)
        XCTAssertEqual(userJson["username"] as? String, "username")
        XCTAssertEqual(userJson["name"] as? String, "First Last")
        XCTAssertEqual(userJson["email"] as? String, "me@email.com")
        XCTAssertEqual(userJson["bio"] as? String, "This is a bio")
        XCTAssertEqual(userJson["phone_number"] as? String, "123-456-7890")
    }
    
    func testFromJSON() {
        var json: [String: Any] = [
            "postid": 1234,
            "text": "this is a post",
            "created_at": "1487975373",
            "num_votes": 10,
            "current_user_vote": 1
        ]
        
        let locJson: [String: Any] = [
            "longitude": 10.0,
            "latitude": 10.0
        ]
 
        let userJson: [String: Any] = [
            "userid": 1,
            "username": "username",
            "name": "First Last",
            "email": "me@email.com",
            "bio": "This is a bio",
            "phone_number": "123-456-7890"
        ]

        json["location"] = locJson
        json["poster"] = userJson
        
        let post = Post(JSON: json)
        XCTAssertNotNil(post)
        XCTAssertEqual(post?.getID()!, 1234)
        XCTAssertEqual(post?.getText(), "this is a post")
        XCTAssertEqual(post?.getTimeAdded(), Date(timeIntervalSince1970: 1487975373))
        XCTAssertEqual(post?.getRating(), 10)
        XCTAssertEqual(post?.getVote(), .upVote)
        
        let location = post?.getLocation()
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.coordinate.longitude, 10.0)
        XCTAssertEqual(location?.coordinate.latitude, 10.0)

        let poster = post?.getPoster()
        XCTAssertNotNil(poster)
        XCTAssertEqual(poster?.getId(), 1)
        XCTAssertEqual(poster?.getUsername(), "username")
        XCTAssertEqual(poster?.getName(), "First Last")
        XCTAssertEqual(poster?.getEmail(), "me@email.com")
        XCTAssertEqual(poster?.getBio(), "This is a bio")
        XCTAssertEqual(poster?.getPhoneNumber(), "123-456-7890")
    }
    
}
