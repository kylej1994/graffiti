//
//  ProfileViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //~~//
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
   
    var posts: [Post] = []
    var user: User? = nil
    
    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPostsByUser()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.contentInset.top = 20
        
        if let user = appDelegate.currentUser {
            print("app delegate current user can be unwrapped")
            self.user = user
        } else {
            print("sadness")
        }
        
        self.getPostsByUser()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        headerLabel.text = user?.getUsername()
        bioLabel.text = user?.getBio()

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
        return self.posts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // create a cell for each table view row
    // would be nice to be able to reuse FeedViewController code...
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 160
        
        let cellIdentifier = "FeedCell"
        // downcast cell to the custom cell class
        // guard safely unwraps the optional
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewTextCell else {
            fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
        }
            
        // this is where we get the post from the post model
        let post = posts[indexPath.row]
            
        cell.textView.text = post.getText()
        setRatingDisplay(cell: cell, post: post)
        setDateDisplay(cell: cell, post: post)
            
        return cell
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
