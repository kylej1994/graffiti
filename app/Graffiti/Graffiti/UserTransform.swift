//
//  UserTransform.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/17/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import ObjectMapper

class UserTransform : TransformType {
    public typealias Object = User
    public typealias JSON = [String : Any]
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> User? {
        guard let json = value as? [String : Any] else {
            return nil
        }
        
        return User(JSON: json)
    }
    
    func transformToJSON(_ value: User?) -> [String : Any]? {
        return value?.toJSON()
    }
}
