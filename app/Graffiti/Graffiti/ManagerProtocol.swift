//
//  ManagerProtocol.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/9/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire

protocol ManagerProtocol {
    func makeRequest(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?,
                 encoding: ParameterEncoding, headers: HTTPHeaders?)  -> RequestProtocol
}

extension Alamofire.SessionManager: ManagerProtocol {
    func makeRequest(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?,
                 encoding: ParameterEncoding, headers: HTTPHeaders?) -> RequestProtocol {
        return request(url, method: method, parameters: parameters,
                       encoding: encoding, headers: headers)
    }
}
