//
//  MockAuth.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/18/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation

class MockAuth : AuthProtocol {
    func getIdToken() -> String? {
        return "Token"
    }
}
