//
//  MockRequest.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/10/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class MockRequest: RequestProtocol {
    @discardableResult
    internal func responseObject<T : BaseMappable>(completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return self
    }

    
    func defaultValidate() -> Self {
        return self
    }
    
    func responseJSON(completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {
        let response: DataResponse<Any> = DataResponse(request: nil, response: nil, data: nil, result: .success("success"))
        completionHandler(response)
        return self
    }
}
