//
//  ApiTests.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest

class ApiTests: XCTestCase {
    var session = MockSessionManager()
    
    override func setUp() {
        super.setUp()
    }
    
    func testDeletePost() {
        let api = API(manager: session)
        api.deletePost(postid: 1234)
        
        let url = session.lastURL as? String
        XCTAssertEqual(url, "/post/1234")
        
        let token = session.lastHeaders?["Authorization"]
        XCTAssertNotNil(token)
    }
    
}
