//
//  ImageTransform.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/26/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageTransform : TransformType {
    public typealias Object = UIImage
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if
            let dataURI = value as? String,
            let dataString = dataURI.components(separatedBy: ";base64,").last,
            let data = Data(base64Encoded: dataString, options: .ignoreUnknownCharacters)
        {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        if
            let image = value,
            let imageData = UIImageJPEGRepresentation(image, 0.5)
        {
            let strBase64 = imageData.base64EncodedString()
            print("image string size: \(strBase64.characters.count)")
            return "data:image/jpeg;base64," + strBase64
        } else {
            return nil
        }
    }
}
