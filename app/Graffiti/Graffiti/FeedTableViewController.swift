//
//  FeedTableViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import CoreLocation
class FeedTableViewController: UITableViewController {
    // todo at some point: add loading animation
    let api = API.sharedInstance
    let locationManager = LocationService.sharedInstance
    var posts: [Post] = []

    var timestamp = "time ago"
    
    var currentLatitude: CLLocationDegrees? = CLLocationDegrees()
    var currentLongitude: CLLocationDegrees? = CLLocationDegrees()
    
    // we load the data in view did appear so the feed gets filled asap
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.getPostsByLocation()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        
        DispatchQueue.main.async {
            self.getPostsByLocation()
            self.tableView.reloadData()
        }
        
        // add refresh control for pull to refresh
        self.refreshControl?.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
    }
    
    
    // get the current location and request list of posts
    func getPostsByLocation() {
        currentLongitude = locationManager.getLongitude()
        currentLatitude = locationManager.getLatitude()
        
        // Bypass Simulator
        if currentLongitude == nil {
            print("long was nil so setting to default")
            currentLongitude = 0.0
        }
        if currentLatitude == nil {
            print("lat was nil so setting to default")
            currentLatitude = 0.0
        }
        
        // Get Posts
        api.getPosts(longitude: currentLongitude!, latitude: currentLatitude!) { response in
            switch response.result {
            case .success:
                if let json = response.result.value as? [String:Any],
                    let posts = json["posts"] as? [Post] {
                    self.posts = posts
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = posts.count
        
        // Display a message about lack of posts when there are no posts
        if numRows == 0 {
            setupEmptyBackgroundView()
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        
        return numRows
    }
    
    // TODO refactor this
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FeedCell"

        // downcast cell to the custom cell class
        // guard safely unwraps the optional
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewTextCell else {
            fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
        }
        
        // get the Post from the array of Posts and fill the cell accordingly
        let post = posts[indexPath.row]
        cell.textView.text = post.getText()
        setDisplay(cell: cell, post: post)
        
        // handle upvote button tap
        cell.upvoteTapAction = { (cell) in
            let indexOfPost = tableView.indexPath(for: cell)!.row
            let chosenPost = self.posts[indexOfPost]
            
            switch chosenPost.getVote() {
            case .noVote:
                chosenPost.upVote()
                if let postid = chosenPost.getID() {
                    self.sendVoteFor(postid: postid, vote: VoteType.upVote)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            // if the post was already upvoted, we send a noVote to undo the vote
            case .upVote:
                chosenPost.noVote()
                if let postid = chosenPost.getID() {
                    self.sendVoteFor(postid: postid, vote: VoteType.noVote)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            // if the user decides to upvote a post previously downvoted, the server handles it
            case .downVote:
                chosenPost.noVote()
                chosenPost.upVote()
                if let postid = chosenPost.getID() {
                    self.sendVoteFor(postid: postid, vote: VoteType.upVote)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            }
            
            // update display
            self.setDisplay(cell: cell, post: chosenPost)
        }
        
        // handle downvote button tap
        cell.downvoteTapAction = { (cell) in
            let indexOfPost = tableView.indexPath(for: cell)!.row
            let chosenPost = self.posts[indexOfPost]
            
            switch chosenPost.getVote() {
            case .noVote:
                chosenPost.downVote()
                if let postid = chosenPost.getID() {
                    self.sendVoteFor(postid: postid, vote: VoteType.downVote)
                } else {
                    print("couldn't get postid. not sending downvote to server, but faking it in ui")
                }
            // if the post was already downvoted, we send a noVote to undo the vote
            case .downVote:
                chosenPost.noVote()
                if let postid = chosenPost.getID() {
                    self.sendVoteFor(postid: postid, vote: VoteType.noVote)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            // if the user decides to downvote a post previously upvoted, the server handles it
            case .upVote:
                chosenPost.noVote()
                chosenPost.downVote()
                if let postid = chosenPost.getID() {
                    self.sendVoteFor(postid: postid, vote: VoteType.downVote)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            }
            
            // update display
            self.setDisplay(cell: cell, post: chosenPost)
        }

        return cell
    }
    
    func setDisplay(cell: FeedTableViewTextCell, post: Post) {
        setRatingDisplay(cell: cell, post: post)
        setDateDisplay(cell: cell, post: post)
        setVoteButtonDisplay(cell: cell, post: post)
    }
    
    func setRatingDisplay(cell: FeedTableViewTextCell, post: Post) {
        let rating = post.getRating()
        cell.votesLabel.text = String(rating)
        if rating < 0 {
            cell.votesLabel.textColor = UIColor(red:0.76, green:0.25, blue:0.25, alpha:1.0)
        } else {
            cell.votesLabel.textColor = UIColor(red:0.40, green:0.78, blue:0.49, alpha:1.0)
        }
    }
    
    func setVoteButtonDisplay(cell: FeedTableViewTextCell, post: Post) {
        let vote = post.getVote()
        switch vote {
        case .upVote:
            cell.upvoteButton.setImage(UIImage(named: "upvote-green-50"), for: .normal)
            cell.downvoteButton.setImage(UIImage(named: "downvote-black-50"), for: .normal)
        case .downVote:
            cell.downvoteButton.setImage(UIImage(named: "downvote-red-50"), for: .normal)
            cell.upvoteButton.setImage(UIImage(named: "upvote-black-50"), for: .normal)
        case .noVote:
            cell.downvoteButton.setImage(UIImage(named: "downvote-black-50"), for: .normal)
            cell.upvoteButton.setImage(UIImage(named: "upvote-black-50"), for: .normal)
        }
    }
    
    func setDateDisplay(cell: FeedTableViewTextCell, post: Post) {
        if let dateAdded = post.getTimeAdded() {
            cell.dateLabel.text = getFormattedDate(date: dateAdded)
        } else {
            cell.dateLabel.text = "Just Now"
        }
    }
    
    
    // todo: read server response, use to update model
    func sendVoteFor(postid: Int, vote: VoteType) {
        api.voteOnPost(postid: postid, vote: vote) { response in
            switch response.result {
            case .success:
                print("sending vote")
                let updatedPost = response.result.value
                print(updatedPost?.getRating() as Any)
            case .failure(let error):
                print("sending vote failed")
                print(error)
            }
        }
    }
    
    // Refresh the feed (request posts from API and fill the table) when user pulls down on table
    func refreshFeed(sender: UIRefreshControl) {
        print("we will refresh here")
        getPostsByLocation()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // convert the date from the date posted to time since posted
    func getFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        return formatter.timeSince(from: date as NSDate, numericDates: true)
    }

}
