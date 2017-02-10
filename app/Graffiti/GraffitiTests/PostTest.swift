
//
//  PostTest.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Graffiti

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
        
        let date: NSDate = NSDate.init()
        
        let latitude: Double = 41.792199
        let longitude: Double = -87.599691
        let secretLocation: CLLocation = CLLocation.init(latitude: latitude, longitude: longitude)
        
        let Jlatitude: Double = 41.796673
        let Jlongitude: Double = -87.605184
        let SUPERsecretLocation: CLLocation = CLLocation.init(latitude: Jlatitude, longitude: Jlongitude)
        
        let dramaticBlabber: String = "According to all known laws of aviation,there is no way a bee should be able to fly.Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible.Yellow, black. Yellow, black.Yellow, black. Yellow, black. Ooh, black and yellow! Let's shake it up a little.Barry! Breakfast is ready!Coming! Hang on a second. Hello? - Barry? - Adam? - Can you believe this is happening?- I can't. I'll pick you up. Looking sharp. Use the stairs. Your father paid good money for those. Sorry. I'm excited. Here's the graduate. We're very proud of you, son. A perfect report card, all B's. Very proud.Ma! I got a thing going here. - You got lint on your fuzz. - Ow! That's me! - Wave to us! We'll be in row 118,000. - Bye! Barry, I told you,stop flying in the house! - Hey, Adam. - Hey, Barry. - Is that fuzz gel? - A little. Special day, graduation. Never thought I'd make it. Three days grade school, three days high school. Those were awkward. Three days college. I'm glad I took a day and hitchhiked around the hive. You did come back different.- Hi, Barry."
        
        let tooManyCharsPost: Post = Post(ID: 1, text: dramaticBlabber, image: nil, timeAdded: date, location: secretLocation, includeTag: false, visibilityType: VisType.Public.rawValue, lifetime: 7)!
        XCTAssertNil(tooManyCharsPost)
        
        // A test to make sure we're capable of creating a post
        let passPost: Post = Post(ID: 1, text: "This is a passing post!", image: nil, timeAdded: date, location: secretLocation, includeTag: false, visibilityType: VisType.Public.rawValue, lifetime: 7)!
        XCTAssertNotNil(passPost)
        
        
        
    }
    
}
