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
    @IBOutlet weak var dateLabel: UILabel!
    
    // http://candycode.io/how-to-properly-do-buttons-in-table-view-cells-using-swift-closures/
    var upvoteTapAction: ((UITableViewCell) -> Void)?
    var downvoteTapAction: ((UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func tapUpvote(_ sender: Any) {
        upvoteTapAction?(self)
    }
    @IBAction func tapDownvote(_ sender: UIButton) {
        downvoteTapAction?(self)
    }
}
