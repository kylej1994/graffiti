//
//  FeedTableViewTextCell.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/12/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class FeedTableViewTextCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var votesLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}