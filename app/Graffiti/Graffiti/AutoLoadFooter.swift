//
//  AutoLoadFooter.swift
//  Graffiti
//
//  Created by Henry Lewis on 3/8/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation

class AutoLoadFooter: UIView {
    var label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 20))
        setLoadingText()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        label.textColor = UIColor.darkGray
        label.center = self.center

        self.addSubview(label)
    }
    
    func setLoadingText() {
        label.text = "Loading more posts..."
    }
    
    func setNoMoreText() {
        label.text = "No more posts"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
