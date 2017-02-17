//
//  FeedTableViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import CoreLocation //see if i can delete
class FeedTableViewController: UITableViewController {
    // reference: https://github.com/uchicago-mobi/mpcs51030-2016-winter-assignment-5-aaizuss/blob/master/Issues/Issues/DataTableViewController.swift
    // activty indicator var
    let api = API.sharedInstance
    let locationManager = LocationService.sharedInstance
    var posts: [Post] = []

    var timestamp = "time ago"
    // computed properties
    var formatter = DateFormatter()
    var formattedTimestamp: String {
        get {
            // code to execute when getting
            // The getter must return a value of the same type
            let time = Date()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.dateStyle = DateFormatter.Style.long
            formatter.timeStyle = .short
            timestamp = "stamp: " + formatter.string(from: time)
            return timestamp
        }
        set {
            print("setting date")
        }
    }
    var currentLatitude: CLLocationDegrees? = CLLocationDegrees()
    var currentLongitude: CLLocationDegrees? = CLLocationDegrees()
    
    func getPostsByLocation() {
        // make network request
        currentLongitude = locationManager.getLongitude()
        currentLatitude = locationManager.getLatitude()
        if currentLongitude == nil {
            print("long was nil so setting to default")
            currentLongitude = 41.792279
        }
        if currentLatitude == nil {
            print("lat was nil so setting to default")
            currentLatitude = -87.599954
        }
        
        api.getPosts(longitude: currentLongitude!, latitude: currentLatitude!) { response in
            switch response.result {
            case .success:
                print("hello i am in success")
                if let json = response.result.value as? [String:Any],
                    let posts = json["posts"] as? [Post] {
                    print(posts)
                    self.posts = posts
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        getPostsByLocation()

        // add refresh control
        self.refreshControl?.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = posts.count
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FeedCell"

        // downcast cell to the custom cell class
        // guard safely unwraps the optional
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewTextCell else {
            fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
        }
        
        // this is where we get the post from the post model
        let post = posts[indexPath.row]
        var rating = post.getRating()

        cell.textView.text = post.getText()
        cell.votesLabel.text = String(rating)
        
        //cell.dateLabel.text = post.getTimeAdded()
        
        // voting
        var didUpvote = false
        var didDownvote = false
        cell.upvoteTapAction = { (cell) in
            didDownvote = false
            if !didUpvote {
                print("entering the upvote stuff")
                didUpvote = true
                self.handleUpvote(cell: cell, currentRating: rating)
                rating += 1 // this seems redundant but it isn't. setting the post rating doesn't work unless we refresh the table
                post.setRating(rating + 1)
                let indexOfPost = tableView.indexPath(for: cell)!.row
                if let postid = self.posts[indexOfPost].getID() {
                    self.sendVoteFor(postid: postid, vote: 1)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            } else {
                print("ignoring upvote button press")
            }
        }

        cell.downvoteTapAction = { (cell) in
            didUpvote = true
            if !didDownvote {
                didDownvote = true
                self.handleDownvote(cell: cell, currentRating: rating)
                rating -= 1
                post.setRating(rating - 1)
                let indexOfPost = tableView.indexPath(for: cell)!.row
                if let postid = self.posts[indexOfPost].getID() {
                    self.sendVoteFor(postid: postid, vote: -1)
                } else {
                    print("couldn't get postid. not sending upvote to server, but faking it in ui")
                }
            } else {
                print("ignoring downvote button press")
            }
        }
        return cell
    }
    
    func handleUpvote(cell: FeedTableViewTextCell, currentRating: Int) {
        cell.upvoteButton.setImage(UIImage(named: "upvote-green-50"), for: .normal)
        cell.downvoteButton.setImage(UIImage(named: "downvote-black-50"), for: .normal)
        cell.votesLabel.text = String(currentRating + 1)
    }
    
    func handleDownvote(cell: FeedTableViewTextCell, currentRating: Int) {
        cell.downvoteButton.setImage(UIImage(named: "downvote-red-50"), for: .normal)
        cell.upvoteButton.setImage(UIImage(named: "upvote-black-50"), for: .normal)
        cell.votesLabel.text = String(currentRating - 1)
    }
    
    // todo: change second param from int to enum: upvote or downvote
    func sendVoteFor(postid: Int, vote: Int) {
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
    
    
    func refreshFeed(sender: UIRefreshControl) {
        print("we will refresh here")
        getPostsByLocation()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
        timestamp = self.formattedTimestamp
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
