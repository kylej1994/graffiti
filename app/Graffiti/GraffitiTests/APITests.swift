//
//  APITests.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest

//TODO test method and parameters
//     Also responses

class ApiTests: XCTestCase {
    let session = MockSessionManager()
    var api: API!
    
    override func setUp() {
        super.setUp()
        
        api = API(manager: session)
    }
    
    //MARK: User Call Tests
    func testGetUser() {
        api.getUser(userid: 1234)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/user/1234")
        
        XCTAssertEqual(session.lastMethod, .get)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testUpdateUser() {
        let user = [
            "username": "username",
            "name": "name",
            "email": "email",
            "textTag": "textTag"
        ] as [String : Any]
        
        api.updateUser(userid: 1234, user: user)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/user/1234")
        
        XCTAssertEqual(session.lastMethod, .put)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testLogin() {
        api.login()
        
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
                "longitude": 10,
                "latitude": 10
            ]
        ] as [String : Any]
        
        api.createPost(post: post)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post")
        
        XCTAssertEqual(session.lastMethod, .post)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testDeletePost() {
        api.deletePost(postid: 1234)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        XCTAssertEqual(session.lastMethod, .delete)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testGetPost() {
        api.getPost(postid: 1234)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        XCTAssertEqual(session.lastMethod, .get)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testGetPostByLocation() {
        api.getPost(longitude: 10, latitude: 10)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post")
        
        XCTAssertEqual(session.lastMethod, .get)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
    func testVoteOnPost() {
        api.voteOnPost(postid: 1234, vote: 1)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        XCTAssertEqual(session.lastMethod, .put)
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
}
