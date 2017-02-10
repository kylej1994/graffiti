//
//  MockSessionManager.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire

class MockSessionManager: ManagerProtocol {
    var lastURL: URLConvertible?
    var lastHeaders: HTTPHeaders?
    var lastMethod: HTTPMethod?
    var lastParameters: Parameters?
    
    func makeRequest(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?,
                 encoding: ParameterEncoding, headers: HTTPHeaders?)  -> RequestProtocol {
        lastURL = url
        lastHeaders = headers
        lastMethod = method
        lastParameters = parameters
        
        // Dummy DataRequest
        return MockRequest()
    }
}