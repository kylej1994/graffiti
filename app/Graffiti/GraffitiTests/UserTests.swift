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
}
