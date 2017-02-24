//
//  UserTests.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest

let longUN: String = "This is a username whch is way too long. In fact this username is so long I'm not even certain that it still counts as a username. Maybe it's just a paragraph. The world may never know."

class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Function to test initialization of users
    func testInit() {
        let testUser:User = User(id: 1, username: "willem", name: "Will", email: "w@uchicago.edu")
        XCTAssertNotNil(testUser)
    }
    
    func testSetUsername() {
        let testUser:User = User(id: 1, username: "willem", name: "Will", email: "w@uchicago.edu")
        
        do {
            _ = try testUser.setUsername(longUN)
        } catch let e as UserError {
            XCTAssertEqual(e, UserError.tooManyChars)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
    func testToJSON() {
        let user = User(id: 1, username: "username", name: "First Last", email: "me@email.com", phoneNumber: "123-456-7890", bio: "This is a bio")
        
        let json: [String: Any] = user.toJSON()
        XCTAssertEqual(json["userid"] as? Int, 1)
        XCTAssertEqual(json["username"] as? String, "username")
        XCTAssertEqual(json["name"] as? String, "First Last")
        XCTAssertEqual(json["email"] as? String, "me@email.com")
        XCTAssertEqual(json["bio"] as? String, "This is a bio")
        XCTAssertEqual(json["phone_number"] as? String, "123-456-7890")
    }
    
    func testFromJSON() {
        let json: [String: Any] = [
            "userid": 1,
            "username": "username",
            "name": "First Last",
            "email": "me@email.com",
            "bio": "This is a bio",
            "phone_number": "123-456-7890"
        ]
        
        let user = User(JSON: json)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.getId(), 1)
        XCTAssertEqual(user?.getUsername(), "username")
        XCTAssertEqual(user?.getName(), "First Last")
        XCTAssertEqual(user?.getEmail(), "me@email.com")
        XCTAssertEqual(user?.getBio(), "This is a bio")
        XCTAssertEqual(user?.getPhoneNumber(), "123-456-7890")
    }

}
