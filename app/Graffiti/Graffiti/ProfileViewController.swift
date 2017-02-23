//
//  ProfileViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var posts: [Post] = []
    var user: User? = nil
    
    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset.top = 20
        
        if let user = appDelegate.currentUser {
            print("app delegate current user can be unwrapped")
            self.user = user
        } else {
            print("sadness")
        }
        
        self.getPostsByUser()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    
    func getPostsByUser() {
        
        let uId: Int = user!.getId()
        
        // make network request
        API.sharedInstance.getUserPosts(userid: uId) { response in
            switch response.result {
            case .success:
                if let json = response.result.value as? [String:Any],
                    let posts = json["posts"] as? [Post] {
                    self.posts = posts
                    self.tableView.reloadData() //essential for table to actually display the data
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // create a cell for each table view row
    // would be nice to be able to reuse FeedViewController code...
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cellReuseIdentifier = "header"
            let cell:ProfileHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ProfileHeaderCell
            tableView.rowHeight = 160
            if let username = user!.getUsername() {
                cell.usernameLabel.text = username
            }
            
            if let tag = user!.getUserImage() {
                cell.profileImageView.image = tag
            }
            
            if let bio = user!.getBio() {
                cell.bioLabel.text = bio
            }
        
            return cell
        } else {
            let cellIdentifier = "FeedCell"
            // downcast cell to the custom cell class
            // guard safely unwraps the optional
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewTextCell else {
                fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
            }
            
            // this is where we get the post from the post model
            let post = posts[indexPath.row - 1]
            
            cell.textView.text = post.getText()
            setRatingDisplay(cell: cell, post: post)
            setDateDisplay(cell: cell, post: post)
            
            return cell
        }
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
    
    func setDateDisplay(cell: FeedTableViewTextCell, post: Post) {
        if let dateAdded = post.getTimeAdded() {
            cell.dateLabel.text = getFormattedDate(date: dateAdded)
        } else {
            cell.dateLabel.text = "Just Now"
        }
    }
    
    func getFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        return formatter.timeSince(from: date as NSDate, numericDates: true)
    }
    
    @IBAction func tapSignOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().disconnect()
    }
}
