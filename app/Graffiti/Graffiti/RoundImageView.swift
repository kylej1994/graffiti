//
//  RoundImageView.swift
//  Graffiti
//
//  Created by Henry Lewis on 3/3/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation

class RoundImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
}
