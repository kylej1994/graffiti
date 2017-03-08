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
    let api = API.sharedInstance
    let locationManager = LocationService.sharedInstance
    var posts: [Post] = []
    var earliestPostTime: Date?
    var requestInflight: Bool = false

    let timestamp = "time ago"
    let pageSize = 15
    
    let autoLoadRatio: CGFloat = 0.8
    var endOfAutoLoad: Bool = false
    var autoLoadFooter: AutoLoadFooter!
    
    var currentLatitude: CLLocationDegrees? = CLLocationDegrees()
    var currentLongitude: CLLocationDegrees? = CLLocationDegrees()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        
        let logo = UIImage(named: "logo-text-black.pdf")
        let imageView = UIImageView(image:logo)
        // let screenSize: CGRect = UIScreen.main.bounds
        // imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width * 0.15, height: screenSize.height * 0.15)
        self.navigationItem.titleView = imageView

        // refresh feed if no posts
        if posts.count == 0 {
            self.getPostsByLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.startUpdatingLocation()
        locationManager.addOnceListener() { _ in
            self.getPostsByLocation()
        }
        
        // add refresh control for pull to refresh
        self.refreshControl?.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        
        // the table view is told to use the Auto Layout constraints
        //  and the contents of its cells to determine each cell’s height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        
        autoLoadFooter = AutoLoadFooter(frame: CGRect(0, 0, tableView.bounds.width, 100))
        autoLoadFooter.isHidden = true
        tableView.tableFooterView = autoLoadFooter
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = contentHeight - contentYoffset
        
        // Always at bottom
        if contentHeight < height {
            return
        }
        
        let progress = (contentYoffset + height) / contentHeight
        if (progress > self.autoLoadRatio) ||  (distanceFromBottom < height) {
            if !self.requestInflight && !self.endOfAutoLoad {
                print(" you reached end of the table")
                getPostsByLocation(nextPage: true)
            }
        }
    }
    
    func resetAutoLoad() {
        self.endOfAutoLoad = false
        self.autoLoadFooter.setLoadingText()
    }
    
    func setNoMorePosts() {
        self.endOfAutoLoad = true
        self.autoLoadFooter.setNoMoreText()
    }
    
    
    // get the current location and request list of posts
    func getPostsByLocation(nextPage: Bool = false) {
        self.requestInflight = true
        
        if self.posts.count == 0 {
            self.showLoadingPostsTable()
        }
        
        guard
            let currentLongitude = locationManager.getLongitude(),
            let currentLatitude = locationManager.getLatitude()
            else {
                return
        }
        
        let before = nextPage ? self.earliestPostTime : nil
        
        // Reset
        if !nextPage {
            self.resetAutoLoad()
        }
        
        // Get Posts
        api.getPosts(longitude: currentLongitude, latitude: currentLatitude, before: before) { response in
            switch response.result {
            case .success:
                if let json = response.result.value as? [String:Any],
                    let posts = json["posts"] as? [Post] {
                    
                    if nextPage {
                        if posts.count > 0 {
                            let start_index = self.posts.count
                            var indexPaths: [IndexPath] = []
                            for row in (start_index..<start_index + posts.count) {
                                indexPaths.append(IndexPath(row: row, section: 0))
                            }
                            
                            self.posts = self.posts + posts
                            self.tableView.insertRows(at: indexPaths, with: .none)
                        } else {
                            self.setNoMorePosts()
                        }
                    } else {
                        self.posts = posts
                        self.tableView.reloadData()
                    }
                    
                    self.earliestPostTime = posts.last?.getTimeAdded()?.addingTimeInterval(-0.001) ?? self.earliestPostTime
                    
                    if self.posts.count == 0 {
                        self.showNoPostsTable()
                    }
                }
            case .failure(let error):
                print(error)
                self.showFeedFailureAlert()
            }
            
            self.requestInflight = false
        }
    }
    
    // todo: test this - ask server to return no posts
    func showNoPostsTable() {
        setupEmptyBackgroundView(withMessage: "There are no posts nearby.")
        tableView.separatorStyle = .none
        tableView.backgroundView?.isHidden = false
    }
    
    func showLoadingPostsTable() {
        setupEmptyBackgroundView(withMessage: "Looking for posts...")
        tableView.separatorStyle = .none
        tableView.backgroundView?.isHidden = false
    }
    
    func setupTableViewForNumRows(_ numRows: Int) {
        if numRows == 0 {
            showLoadingPostsTable()
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = posts.count
        
        if numRows >= self.pageSize {
            self.autoLoadFooter.isHidden = false
        } else {
            self.autoLoadFooter.isHidden = true
        }
        
        setupTableViewForNumRows(numRows)
        
        return numRows
    }
    
    // TODO refactor this
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textCellIdentifier = "FeedCell"
        let imageCellIdentifier = "ImageCell"

        // get the Post from the array of Posts and fill the cell accordingly
        let post = posts[indexPath.row]
        let type = post.getPostType()
        
        // downcast cell to the custom cell class
        // guard safely unwraps the optional
        guard var cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as? FeedTableViewCell else {
            fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
        }

        if type == .TextPost {
            guard let textCell = cell as? FeedTextCell else {
                fatalError("The dequeue cell is not an instance of FeedTextCell.")
            }
            textCell.textView.text = post.getText()
        }
        
        if type == .ImagePost {
            cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! FeedImageCell // necessary or else the dequeue cell is the wrong class
            guard let imageCell = cell as? FeedImageCell else {
                fatalError("The dequeue cell is not an instance of FeedTextCell.")
            }
            imageCell.feedImageView.image = post.getImage()
            imageCell.feedImageView.tag = indexPath.row

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage(sender:)))
            imageCell.feedImageView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        setDisplay(cell: cell, post: post)

        // handle upvote button tap
        cell.upvoteTapAction = { (cell) in
            let chosenPath = tableView.indexPath(for: cell)!
            let chosenPost = self.posts[chosenPath.row]
            
            let oldVote = chosenPost.getVote()
            let oldRating = chosenPost.getRating()
            let resetVote: () -> () = { _ in
                chosenPost.setVote(oldVote)
                chosenPost.setRating(oldRating)
                self.tableView.reloadRows(at: [chosenPath], with: .none)
            }
            
            switch chosenPost.getVote() {
            case .noVote:
                chosenPost.upVote()
                self.sendVoteFor(indexPath: chosenPath, vote: VoteType.upVote, resetVote: resetVote)
            // if the post was already upvoted, we send a noVote to undo the vote
            case .upVote:
                chosenPost.noVote()
                self.sendVoteFor(indexPath: chosenPath, vote: VoteType.noVote, resetVote: resetVote)
            // if the user decides to upvote a post previously downvoted, the server handles it
            case .downVote:
                chosenPost.noVote()
                chosenPost.upVote()
                self.sendVoteFor(indexPath: chosenPath, vote: VoteType.upVote, resetVote: resetVote)
            }
            
            // update display
            self.setVoteDisplay(cell: cell, post: chosenPost)
        }
        
        // handle downvote button tap
        cell.downvoteTapAction = { (cell) in
            let chosenPath = tableView.indexPath(for: cell)!
            let chosenPost = self.posts[chosenPath.row]

            let oldVote = chosenPost.getVote()
            let oldRating = chosenPost.getRating()
            let resetVote: () -> () = { _ in
                chosenPost.setVote(oldVote)
                chosenPost.setRating(oldRating)
                self.tableView.reloadRows(at: [chosenPath], with: .none)
            }
            
            switch chosenPost.getVote() {
            case .noVote:
                chosenPost.downVote()
                self.sendVoteFor(indexPath: chosenPath, vote: VoteType.downVote, resetVote: resetVote)
            // if the post was already downvoted, we send a noVote to undo the vote
            case .downVote:
                chosenPost.noVote()
                self.sendVoteFor(indexPath: chosenPath, vote: VoteType.noVote, resetVote: resetVote)
            // if the user decides to downvote a post previously upvoted, the server handles it
            case .upVote:
                chosenPost.noVote()
                chosenPost.downVote()
                self.sendVoteFor(indexPath: chosenPath, vote: VoteType.downVote, resetVote: resetVote)
            }
            
            // update display
            self.setVoteDisplay(cell: cell, post: chosenPost)
        }

        return cell
    }
    
    func setDisplay(cell: FeedTableViewCell, post: Post) {
        setDateDisplay(cell: cell, post: post)
        setProfPicDisplay(cell: cell, post: post)
        setVoteDisplay(cell: cell, post: post)
    }
    
    func setDateDisplay(cell: FeedTableViewCell, post: Post) {
        if let dateAdded = post.getTimeAdded() {
            cell.dateLabel.text = getFormattedDate(date: dateAdded)
        } else {
            cell.dateLabel.text = "Just Now"
        }
    }
    
    func setProfPicDisplay(cell: FeedTableViewCell, post: Post) {
        guard let poster = post.getPoster() else {
            return
        }
        guard let photo = poster.getImageTag() else {
            return
        }
        guard cell.profPicImageView != nil else {
            return
        }
        cell.profPicImageView.image = photo
    }
    
    func setVoteDisplay(cell: FeedTableViewCell, post: Post) {
        setRatingDisplay(cell: cell, post: post)
        setVoteButtonDisplay(cell: cell, post: post)
    }
    
    func setRatingDisplay(cell: FeedTableViewCell, post: Post) {
        let rating = post.getRating()
        cell.votesLabel.text = String(rating)
        if rating < 0 {
            cell.votesLabel.textColor = UIColor(red:0.76, green:0.25, blue:0.25, alpha:1.0)
        } else {
            cell.votesLabel.textColor = UIColor(red:0.40, green:0.78, blue:0.49, alpha:1.0)
        }
    }
    
    func setVoteButtonDisplay(cell: FeedTableViewCell, post: Post) {
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
    
    func sendVoteFor(indexPath: IndexPath, vote: VoteType, resetVote: @escaping () -> ()) {
        let post = posts[indexPath.row]
        if let postid = post.getID() {
            api.voteOnPost(postid: postid, vote: vote) { response in
                switch response.result {
                case .success:
                    if let postFromServer = response.result.value {
                        // set post rating and vote based on the server's response
                        post.setRating(postFromServer.getRating())
                        post.setVote(postFromServer.getVote())
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                        print("just updated post model: vote: \(post.getVote()) rating: \(post.getRating())")
                    }
                case .failure(let error):
                    print("sending vote failed")
                    resetVote()
                    print(error)
                }
            }
        } else {
            print("couldn't get postid.")
        }
    }
    
    // Refresh the feed (request posts from API and fill the table) when user pulls down on table
    func refreshFeed(sender: UIRefreshControl) {
        getPostsByLocation()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // convert the date from the date posted to time since posted
    func getFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        return formatter.timeSince(from: date as NSDate, numericDates: true)
    }
    
    func showAlert(messageTitle: String, message: String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showFeedFailureAlert() {
        showAlert(messageTitle: "Can't load latest posts", message: "")
    }
    
    
    func didTapImage(sender: UITapGestureRecognizer) {
        let cellImageView = sender.view as! UIImageView
        
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController {
            detailVC.modalTransitionStyle = .crossDissolve
            detailVC.view.backgroundColor = UIColor.black

            present(detailVC, animated: true, completion: nil)
            if let theImage = cellImageView.image {
                detailVC.imageDetailView.image = theImage
            }
        }
    }
    
        func addPostToTop(newpost: Post){
            self.posts.insert(newpost, at: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
            
        }
        
    }
    
    
    


