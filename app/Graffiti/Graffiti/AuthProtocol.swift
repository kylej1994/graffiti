//
//  AuthProtocol.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/18/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import GoogleSignIn

protocol AuthProtocol {
    func getIdToken() -> String?
}

extension GIDSignIn : AuthProtocol {
    func getIdToken() -> String? {
        return self.currentUser?.authentication?.idToken
    }
}
