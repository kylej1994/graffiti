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
    
    func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?,
                 encoding: ParameterEncoding, headers: HTTPHeaders?)  -> DataRequest {
        lastURL = url
        lastHeaders = headers
        
        // Dummy DataRequest
        return Alamofire.request(url)
    }
}
