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
import GoogleSignIn

// A completion closure invoked when requests complete
typealias Handler = (DataResponse<Any>) -> Void
typealias PostHandler = (DataResponse<Post>) -> Void
typealias UserHandler = (DataResponse<User>) -> Void

typealias RequestHandler = (Result<RequestProtocol>) -> Void

enum APIError: Error {
    case misformedAPIResponse
    case userNotSignedIn
    case noIdToken
}


// A Service that executes network requests to the Graffiti API
// For more information about API endpoints see
// https://github.com/kylej1994/graffiti/wiki/API-Documentation
class API {
    static let sharedInstance = API()
    
    //MARK Properties
    private let manager: ManagerProtocol
    private let auth: AuthProtocol
    //private let baseUrl = "http://127.0.0.1:5000"
    private let baseUrl = "http://docker-graffiti-dev.us-east-2.elasticbeanstalk.com"
    
    init(manager: ManagerProtocol = Alamofire.SessionManager.default, auth: AuthProtocol = GIDSignIn.sharedInstance()) {
        self.manager = manager
        self.auth = auth
    }
    
    //MARK Private Methods
    @discardableResult private func makeRequest(_ url: String, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, handler: @escaping RequestHandler) {
        
        auth.getIdToken() { tokenResult in
            switch tokenResult {
            case .success:
                guard let idToken = tokenResult.value else {
                    handler(Result.failure(APIError.noIdToken))
                    return
                }
                
                // Attach idToken
                let headers = ["Authorization": "Bearer \(idToken)"]
                
                // Construct Url
                let fullUrl = self.baseUrl + url
                
                // Make request
                let request = self.manager.makeRequest(fullUrl, method: method, parameters: parameters,
                                                       encoding: encoding, headers: headers).defaultValidate()
                handler(Result.success(request))
            case .failure(let error):
                handler(Result.failure(error))
            }
        }
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
    
    // Unwraps and converts JSON to JSON with bool and User object
    private func loginHandler(response: DataResponse<Any>, handler: Handler) {
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
    
    //MARK: User Calls
    func getUser(userid: Int, handler: @escaping UserHandler) {
        makeRequest("/user/\(userid)", method: .get) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseObject(completionHandler: handler)
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func updateUser(user: User, handler: @escaping UserHandler) {
        let userParams : Parameters = user.toJSON()
        makeRequest("/user/\(user.getId())", method: .put, parameters: userParams, encoding: JSONEncoding.default) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseObject(completionHandler: handler)
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func login(handler: @escaping Handler) {
        makeRequest("/user/login", method: .get) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseJSON() { response in
                    self.loginHandler(response: response, handler: handler)
                }
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func getUserPosts(userid: Int, handler: @escaping Handler) {
        makeRequest("/user/\(userid)/posts", method: .get) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseJSON() { response in
                    self.postsHandler(response: response, handler: handler)
                }
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    //MARK: Post Calls
    func createPost(post: Post, handler: @escaping PostHandler) {
        let postParams : Parameters = post.toJSON()
        makeRequest("/post", method: .post, parameters: postParams, encoding: JSONEncoding.default) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseObject(completionHandler: handler)
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func deletePost(postid: Int, handler: @escaping PostHandler) {
        makeRequest("/post/\(postid)", method: .delete) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseObject(completionHandler: handler)
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func getPost(postid: Int, handler: @escaping PostHandler) {
        makeRequest("/post/\(postid)", method: .get) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseObject(completionHandler: handler)
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func getPosts(longitude: Double, latitude: Double, handler: @escaping Handler) {
        let parameters = [
            "longitude": longitude,
            "latitude": latitude
        ]
        makeRequest("/post", method: .get, parameters: parameters){ requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseJSON() { response in
                    self.postsHandler(response: response, handler: handler)
                }
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
    
    func voteOnPost(postid: Int, vote: VoteType, handler: @escaping PostHandler) {
        let parameters = ["vote": vote.rawValue]
        makeRequest("/post/\(postid)/vote", method: .put, parameters: parameters, encoding: JSONEncoding.default) { requestResult in
            switch requestResult {
            case .success:
                requestResult.value?.responseObject(completionHandler: handler)
            case .failure(let error):
                handler(DataResponse(request: nil, response: nil, data: nil, result: Result.failure(error)))
            }
        }
    }
}
