//
//  AuthProtocol.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/18/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import GoogleSignIn
import Alamofire

protocol AuthProtocol {
    func getIdToken(handler: @escaping (Result<String>) -> Void)
}

extension GIDSignIn : AuthProtocol {
    func getIdToken(handler: @escaping (Result<String>) -> Void) {
        self.currentUser?.authentication?.getTokensWithHandler() { authentication, err in
            if let err = err {
                handler(Result.failure(err))
                return
            }
            
            handler(Result.success(authentication!.idToken))
        }
    }
}
