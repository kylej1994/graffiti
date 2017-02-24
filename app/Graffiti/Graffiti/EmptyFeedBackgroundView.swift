//
//  EmptyFeedBackgroundView.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/15/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit

extension FeedTableViewController {
    func setupEmptyBackgroundView() {
        let emptyView = UIView(frame: view.bounds)
        emptyView.addSubview(label(withMessage: "Looking for posts..."))
        tableView.backgroundView = emptyView
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func label(withMessage text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.darkGray
        label.center = view.center
        return label
    }
}
