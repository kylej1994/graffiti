//
//  API.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

// A completion closure invoked when requests complete
typealias Handler = (DataResponse<Any>) -> Void
typealias PostHandler = (DataResponse<Post>) -> Void
typealias UserHandler = (DataResponse<User>) -> Void

enum APIError: Error {
    case misformedAPIResponse
    case userNotSignedIn
}


// A Service that executes network requests to the Graffiti API
// For more information about API endpoints see
// https://github.com/kylej1994/graffiti/wiki/API-Documentation
class API {
    static let sharedInstance = API()
    
    //MARK Properties
    private let manager: ManagerProtocol
    private let auth: AuthProtocol
    private let baseUrl = "http://127.0.0.1:5000"
    
    init(manager: ManagerProtocol = Alamofire.SessionManager.default, auth: AuthProtocol = GIDSignIn.sharedInstance()) {
        self.manager = manager
        self.auth = auth
    }
    
    //MARK Private Methods
    @discardableResult private func makeRequest(_ url: String, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default) -> RequestProtocol?{
        // Add Authentication token
        guard let idToken = auth.getIdToken() else {
            // User needs to be signed in
            // Navigate to SignIn View?
            return nil
        }
        
        let headers = ["Authorization": "Bearer \(idToken)"]
        
        // Construct Url
        let fullUrl = baseUrl + url
        
        // Make request
        return manager.makeRequest(fullUrl, method: method, parameters: parameters,
                        encoding: encoding, headers: headers)
            .defaultValidate()
    }
    
    // Unwraps and converts JSON to Array of posts to pass to handler
    private func postsHandler(response: DataResponse<Any>, handler: Handler) {
        switch response.result {
        case .success:
            var result : Result<Any>
            do {
                // Unwrap JSON
                guard
                    let json = response.result.value as? [String: Any],
                    let posts = json["posts"] as? [Any]
                    else{
                        throw APIError.misformedAPIResponse
                }
                
                // Map to Post Objects
                let postObjects = try posts.map() { (post) -> Post in
                    if
                        let postJSON = post as? [String : Any],
                        let postObject = Post(JSON: postJSON)
                    {
                        return postObject
                    } else {
                        throw APIError.misformedAPIResponse
                    }
                }
                
                // Form result value
                let value : Any = [
                    "posts": postObjects
                ]
                result = Result.success(value)
            } catch(let error) {
                // Failure
                result = Result.failure(error)
            }
            
            let newResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result)
            handler(newResponse)
        case .failure:
            handler(response)
        }
    }
    
    //MARK: User Calls
    func getUser(userid: Int, handler: @escaping UserHandler) {
        makeRequest("/user/\(userid)", method: .get)?.responseObject(completionHandler: handler)
    }
    
    func updateUser(user: User, handler: @escaping UserHandler) {
        let userParams : Parameters = user.toJSON()
        makeRequest("/user/\(user.getId())", method: .put, parameters: userParams, encoding: JSONEncoding.default)?.responseObject(completionHandler: handler)
    }
    
    func login(handler: @escaping Handler) {
        makeRequest("/user/login", method: .get)?.responseJSON() { response in
            switch response.result {
            case .success:
                var result : Result<Any>
                
                if
                    // Unwrap JSON
                    let json = response.result.value as? [String: Any],
                    let newUser = json["new_user"] as? Bool,
                    let userJSON = json["user"] as? [String : Any],
                    let user = User(JSON: userJSON)
                {
                    // Form result value
                    let value : Any = [
                        "new_user": newUser,
                        "user": user
                    ]
                    result = Result.success(value)
                } else {
                    // Failure
                    result = Result.failure(APIError.misformedAPIResponse)
                }
                
                let newResponse = DataResponse(request: response.request, response: response.response, data: response.data, result: result)
                handler(newResponse)
            case .failure:
                handler(response)
            }
            
        }
    }
    
    //Needs testing
    func getUserPosts(userid: Int, handler: @escaping Handler) {
        makeRequest("/user/\(userid)/posts", method: .get)?.responseJSON() { response in
            self.postsHandler(response: response, handler: handler)
        }
    }
    
    //MARK: Post Calls
    func createPost(post: Post, handler: @escaping PostHandler) {
        let postParams : Parameters = post.toJSON()
        makeRequest("/post", method: .post, parameters: postParams, encoding: JSONEncoding.default)?.responseObject(completionHandler: handler)
    }
    
    func deletePost(postid: Int, handler: @escaping PostHandler) {
        makeRequest("/post/\(postid)", method: .delete)?.responseObject(completionHandler: handler)
    }
    
    func getPost(postid: Int, handler: @escaping PostHandler) {
        makeRequest("/post/\(postid)", method: .get)?.responseObject(completionHandler: handler)
    }
    
    func getPosts(longitude: Double, latitude: Double, handler: @escaping Handler) {
        let parameters = [
            "longitude": longitude,
            "latitude": latitude
        ]
        makeRequest("/post", method: .get, parameters: parameters)?.responseJSON() { response in
            self.postsHandler(response: response, handler: handler)
        }
    }
    
    func voteOnPost(postid: Int, vote: VoteType, handler: @escaping PostHandler) {
        let parameters = ["vote": vote.rawValue]
        makeRequest("/post/\(postid)/vote", method: .put, parameters: parameters, encoding: JSONEncoding.default)?.responseObject(completionHandler: handler)
    }
}
