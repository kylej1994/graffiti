//
//  API.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire

class API {
    private let manager: ManagerProtocol
    
    init(manager: ManagerProtocol = Alamofire.SessionManager.default) {
        self.manager = manager
    }
    
    private func makeRequest(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters? = nil) {
        manager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default,
                        headers: nil)
    }
    
    func deletePost(postid: Int) {
        makeRequest("/post/\(postid)", method: .post)
    }
}
