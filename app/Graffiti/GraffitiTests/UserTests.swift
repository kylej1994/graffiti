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
        let testUser:User = User(username: "willem", name: "Will", email: "w@uchicago.edu", userImage: nil, textTag: nil, imageTag: nil)
        XCTAssertNotNil(testUser)
    }
    
    func testSetUsername() {
        let testUser:User = User(username: "willem", name: "Will", email: "w@uchicago.edu", userImage: nil, textTag: nil, imageTag: nil)
        
        do {
            _ = try testUser.setUsername(_username: longUN)
        } catch let e as UserError {
            XCTAssertEqual(e, UserError.tooManyChars)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
    func testGetTextTag() {
        let testUser:User = User(username: "willem", name: "Will", email: "w@uchicago.edu", userImage: nil, textTag: nil, imageTag: nil)
        
        do {
            _ = try testUser.getTextTag()
        } catch let e as UserError {
            XCTAssertEqual(e, UserError.noTextTag)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
    func testGetImageTag() {
        let testUser:User = User(username: "willem", name: "Will", email: "w@uchicago.edu", userImage: nil, textTag: nil, imageTag: nil)
        
        do {
            _ = try testUser.getImageTag()
        } catch let e as UserError {
            XCTAssertEqual(e, UserError.noImageTag)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
    func testGetUserImage() {
        let testUser:User = User(username: "willem", name: "Will", email: "w@uchicago.edu", userImage: nil, textTag: nil, imageTag: nil)
        
        do {
            _ = try testUser.getUserImage()
        } catch let e as UserError {
            XCTAssertEqual(e, UserError.noImage)
        } catch {
            XCTFail("Wrong Error!")
        }
    }
    
}
