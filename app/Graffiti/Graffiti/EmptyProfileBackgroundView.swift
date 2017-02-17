//
//  EmptyProfileBackgroundView.swift
//  Graffiti
//
//  Created by Will Longendyke on 2/16/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit

extension ProfileViewController {
    func setupEmptyBackgroundView() {
        let emptyView = UIView(frame: view.bounds)
        emptyView.addSubview(label(withMessage: "There's nothing nearby"))
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
