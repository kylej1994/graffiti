//
//  API.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire

typealias Handler = (DataResponse<Any>) -> Void

class API {
    static let sharedInstance = API()
    
    //MARK Properties
    private let manager: ManagerProtocol
    
    init(manager: ManagerProtocol = Alamofire.SessionManager.default) {
        self.manager = manager
    }
    
    //MARK Private Methods
    
    private func makeRequest(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters? = nil, handler: @escaping Handler) {
        // Add Authentication token
        let idToken = "idToken" //TODO
        let headers = ["Authorization": "Bearer \(idToken)"]
        
        // Make request
        manager.request(url, method: method, parameters: parameters,
                        encoding: URLEncoding.default, headers: headers)
            .responseJSON(completionHandler: handler)
    }
    
    //MARK: User Calls
    func getUser(userid: Int, handler: @escaping Handler) {
        makeRequest("/user/\(userid)", method: .get, handler: handler)
    }
    
    func updateUser(userid: Int, user: Parameters, handler: @escaping Handler) {
        makeRequest("/user/\(userid)", method: .put, parameters: user, handler: handler)
    }
    
    func login(handler: @escaping Handler) {
        makeRequest("/user/login", method: .get, handler: handler)
    }
    
    //MARK: Post Calls
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
