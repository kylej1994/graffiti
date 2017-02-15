//
//  API.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire

// A completion closure invoked when requests complete
typealias Handler = (DataResponse<Any>) -> Void


// A Service that executes network requests to the Graffiti API
// For more information about API endpoints see
// https://github.com/kylej1994/graffiti/wiki/API-Documentation
class API {
    static let sharedInstance = API()
    
    //MARK Properties
    private let manager: ManagerProtocol
    private let baseUrl = "http://127.0.0.1:5000"
    
    init(manager: ManagerProtocol = Alamofire.SessionManager.default) {
        self.manager = manager
    }
    
    //MARK Private Methods
    private func makeRequest(_ url: String, method: HTTPMethod, parameters: Parameters? = nil, handler: @escaping Handler) {
        // Add Authentication token
        let idToken = "idToken" //TODO
        let headers = ["Authorization": "Bearer \(idToken)"]
        
        // Construct Url
        let fullUrl = baseUrl + url
        
        // Make request
        manager.makeRequest(fullUrl, method: method, parameters: parameters,
                        encoding: URLEncoding.default, headers: headers)
            .defaultValidate().responseJSON(completionHandler: handler)
    }
    
    //MARK: User Calls
    func getUser(userid: Int, handler: @escaping Handler) {
        makeRequest("/user/\(userid)", method: .get, handler: handler)
    }
    
    func updateUser(user: User, handler: @escaping Handler) {
        var userParams : Parameters = ["userid": user.getId()]
        
        if let username = user.getUsername() {
            userParams["username"] = username
        }
        if let name = user.getName() {
            userParams["name"] = name
        }
        if let email = user.getEmail() {
            userParams["email"] = email
        }
        if let textTag = user.getTextTag() {
            userParams["textTag"] = textTag
        }
        
        makeRequest("/user/\(user.getId())", method: .put, parameters: userParams, handler: handler)
    }
    
    func login(handler: @escaping Handler) {
        makeRequest("/user/login", method: .get, handler: handler)
    }
    
    //MARK: Post Calls
    // todo
    func createPost(post: Parameters, handler: @escaping Handler) { //TODO
        makeRequest("/post", method: .post, parameters: post, handler: handler)
    }
    
    func deletePost(postid: Int, handler: @escaping Handler) {
        makeRequest("/post/\(postid)", method: .delete, handler: handler)
    }
    
    func getPost(postid: Int, handler: @escaping Handler) {
        makeRequest("/post/\(postid)", method: .get, handler: handler)
    }
    
    func getPost(longitude: Double, latitude: Double, handler: @escaping Handler) {
        let parameters = [
            "longitude": longitude,
            "latitude": latitude
        ]
        makeRequest("/post", method: .get, parameters: parameters, handler: handler)
    }
    
    func voteOnPost(postid: Int, vote: Int, handler: @escaping Handler) {
        let parameters = ["vote": vote]
        makeRequest("/post/\(postid)", method: .put, parameters: parameters, handler: handler)
    }
}
