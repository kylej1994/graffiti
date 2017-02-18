//
//  Vote.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/17/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import ObjectMapper

enum VoteType: Int {
    case upVote = 1
    case downVote = -1
    case noVote = 0
}

class VoteTransform : TransformType {
    public typealias Object = VoteType
    public typealias JSON = Int
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> VoteType? {
        guard var voteValue = value as? Int else {
            return nil
        }
        
        if voteValue > 0 {
            voteValue = 1
        } else if voteValue < 0 {
            voteValue = -1
        }
        
        return VoteType(rawValue: voteValue)
    }
    
    func transformToJSON(_ value: VoteType?) -> Int? {
        return value?.rawValue
    }
}
