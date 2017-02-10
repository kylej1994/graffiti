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
    
    @discardableResult func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?,
                 encoding: ParameterEncoding, headers: HTTPHeaders?)  -> DataRequest
}

extension Alamofire.SessionManager: ManagerProtocol { }
