//
//  FeedTableViewTextCell.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/12/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    //@IBOutlet weak var textView: UITextView!
    @IBOutlet weak var profPicImageView: UIImageView!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    // http://candycode.io/how-to-properly-do-buttons-in-table-view-cells-using-swift-closures/
    var upvoteTapAction: ((FeedTableViewCell) -> Void)?
    var downvoteTapAction: ((FeedTableViewCell) -> Void)?
    
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
