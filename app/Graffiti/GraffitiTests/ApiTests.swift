//
//  APITests.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest

class ApiTests: XCTestCase {
    let session = MockSessionManager()
    var api: API!
    
    override func setUp() {
        super.setUp()
        
        api = API(manager: session)
    }
    
    //MARK: User Call Tests
    func testGetUser() {
        api.getUser(userid: 1234) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/user/1234")
        
        XCTAssertEqual(session.lastMethod, .get)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testUpdateUser() {
        let user = User(id: 1234, username: "username", name: "name", email: "email", textTag: "textTag")
        
        api.updateUser(user: user) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/user/1234")
        
        XCTAssertEqual(session.lastMethod, .put)
        XCTAssertEqual(session.lastParameters?["userid"] as! Int, 1234)
        XCTAssertEqual(session.lastParameters?["username"] as! String, "username")
        XCTAssertEqual(session.lastParameters?["name"] as! String, "name")
        XCTAssertEqual(session.lastParameters?["email"] as! String, "email")
        XCTAssertEqual(session.lastParameters?["textTag"] as! String, "textTag")
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testLogin() {
        api.login() { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/user/login")
        
        XCTAssertEqual(session.lastMethod, .get)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    //MARK: Post Call Tests
    
    func testCreatePost() {
        let post = [
            "text": "this is a post",
            "location": [
                "longitude": 10.0,
                "latitude": 10.0
            ]
        ] as [String : Any]
        
        api.createPost(post: post) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post")
        
        XCTAssertEqual(session.lastMethod, .post)
        XCTAssertEqual(session.lastParameters?["text"] as! String, post["text"] as! String)
        XCTAssertEqual(session.lastParameters?["location"] as! [String : Double], post["location"] as! [String : Double])
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testDeletePost() {
        api.deletePost(postid: 1234) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        XCTAssertEqual(session.lastMethod, .delete)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testGetPost() {
        api.getPost(postid: 1234) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        XCTAssertEqual(session.lastMethod, .get)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testGetPostByLocation() {
        let location: [String : Double] = [
            "longitude": 10,
            "latitude": 10
        ]
        api.getPost(longitude: location["longitude"]!, latitude: location["latitude"]!) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post")
        
        XCTAssertEqual(session.lastMethod, .get)
        XCTAssertEqual(session.lastParameters as! [String : Double], location)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testVoteOnPost() {
        let vote: [String : Int] = ["vote": 1]
        api.voteOnPost(postid: 1234, vote: vote["vote"]!) { (_) in }
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        XCTAssertEqual(session.lastMethod, .put)
        XCTAssertEqual(session.lastParameters as! [String : Int], vote)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
}
