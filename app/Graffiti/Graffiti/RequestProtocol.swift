//
//  RequestProtocol.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/10/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestProtocol {
    @discardableResult func responseJSON(completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self

}

extension DataRequest : RequestProtocol {
    func responseJSON(completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {
        return responseJSON(queue: nil, options: .allowFragments, completionHandler: completionHandler)
    }
}

