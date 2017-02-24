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
    func getIdToken(handler: @escaping GIDAuthenticationHandler)
}

extension GIDSignIn : AuthProtocol {
    func getIdToken(handler: @escaping GIDAuthenticationHandler) {
        self.currentUser?.authentication?.getTokensWithHandler(handler)
    }
}
