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
        
        getPostsByUser()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        headerLabel.text = user?.getUsername()
        bioLabel.text = user?.getBio()
        
        // self sizing table view cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
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
    
    //~~~//
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        var tableViewTransform = CATransform3DIdentity
        
        //var tableViewScale = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        // Header -----------
        
        headerTransform = CATransform3DTranslate(headerTransform, 0, -offset, 0)
        
        // Table View -----------
        
        if(offset < 150.0){
            //print(tableView.frame.height.description)
            tableViewTransform = CATransform3DTranslate(tableViewTransform, 0, -offset, 0)
            if(offset > 0.0){
            tableView.frame.size = CGSize(tableView.contentSize.width, tableView.frame.height + offset) //and vice versa when keyboard is dismissed
            }
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
            if(tableView.frame.height > height){
                tableView.frame.size = CGSize(tableView.contentSize.width, height - 80) //and vice versa when keyboard is dismissed
            }
            
            
        } else {
            //print("oh hey")
            tableViewTransform = CATransform3DTranslate(tableViewTransform, 0, -150, 0)
            
        }
        // Avatar -----------
            
        let avatarScaleFactor = (min(offset_HeaderStop, offset)) / profilePicture.bounds.height / 0.8 // Slow down the animation
        let avatarSizeVariation = ((profilePicture.bounds.height * (1.0 + avatarScaleFactor)) - profilePicture.bounds.height) / 1.4
        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
        if offset <= offset_HeaderStop {
            if profilePicture.layer.zPosition < header.layer.zPosition{
                header.layer.zPosition = 0
            }
                
        }else {
            if profilePicture.layer.zPosition >= header.layer.zPosition{
                header.layer.zPosition = 2
            }
        }
        
        tableView.layer.transform = tableViewTransform
        //tableView.layer.transform = tableViewScale
        header.layer.transform = headerTransform
        profilePicture.layer.transform = avatarTransform
    }
    

    //~~~//
    
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
        let textCellIdentifier = "FeedCell"
        let imageCellIdentifier = "ImageCell"
        
        let post = posts[indexPath.row]
        let type = post.getPostType()

        // downcast cell to the custom cell class
        // guard safely unwraps the optional
        guard var cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as? FeedTableViewCell else {
            fatalError("The dequeue cell is not an instance of FeedTableViewCell.")
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
        }
        
        setRatingDisplay(cell: cell, post: post)
        setDateDisplay(cell: cell, post: post)
            
        return cell
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
    
    func setDateDisplay(cell: FeedTableViewCell, post: Post) {
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
