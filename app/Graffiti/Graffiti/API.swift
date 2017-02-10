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
    static let sharedInstance = API()
    
    //MARK Properties
    private let manager: ManagerProtocol
    
    init(manager: ManagerProtocol = Alamofire.SessionManager.default) {
        self.manager = manager
    }
    
    //MARK Private Methods
    
    private func makeRequest(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters? = nil) {
        // Add Authentication token
        let idToken = "idToken" //TODO
        let headers = ["Authorization": "Bearer \(idToken)"]
        
        // Make request
        manager.request(url, method: method, parameters: parameters, encoding: URLEncoding.default,
                        headers: headers)
    }
    
    //MARK: User Calls
    func getUser(userid: Int) {
        makeRequest("/user/\(userid)", method: .get)
    }
    
    func updateUser(userid: Int, user: Parameters) {
        makeRequest("/user/\(userid)", method: .put, parameters: user)
    }
    
    func login() {
        makeRequest("/user/login", method: .get)
    }
    
    //MARK: Post Calls
    func createPost(post: Parameters) { //TODO
        makeRequest("/post", method: .post, parameters: post)
    }
    
    func deletePost(postid: Int) {
        makeRequest("/post/\(postid)", method: .delete)
    }
    
    func getPost(postid: Int) {
        makeRequest("/post/\(postid)", method: .get)
    }
    
    func getPost(longitude: Float, latitude: Float) {
        let parameters = [
            "longitude": longitude,
            "latitude": latitude
        ]
        makeRequest("/post", method: .get, parameters: parameters)
    }
    
    func voteOnPost(postid: Int, vote: Int) {
        let parameters = ["vote": vote]
        makeRequest("/post/\(postid)", method: .put, parameters: parameters)
    }
}
