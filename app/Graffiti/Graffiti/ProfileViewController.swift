//
//  ProfileViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

enum MyRows: Int {
    case banner = 0
    case categories
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "header"
    
    var posts: [Post] = []
    
    var user:User? = nil
    
    var btnDisconnect : UIButton!
    var label : UILabel!
    var btnSignOut: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.getPostsByUser()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset.top = 20
        
        DispatchQueue.main.async {
            self.getPostsByUser()
            self.tableView.reloadData()
        }
        
        // we should change this so we use IBOutlets
        btnSignOut = UIButton(frame: CGRect(0,0,100,30))
        btnSignOut.center = CGPoint(view.center.x, 500)
        btnSignOut.setTitle("Sign Out", for: UIControlState.normal)
        btnSignOut.setTitleColor(UIColor.blue, for: UIControlState.normal)
        btnSignOut.setTitleColor(UIColor.cyan, for: UIControlState.highlighted)
        btnSignOut.addTarget(self, action: #selector(btnSignOutPressed(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(btnSignOut)
        
        btnDisconnect = UIButton(frame: CGRect(0,0,100,30))
        btnDisconnect.center = CGPoint(view.center.x, 200)
        btnDisconnect.setTitle("Disconnect", for: UIControlState.normal)
        btnDisconnect.setTitleColor(UIColor.blue, for: UIControlState.normal)
        btnDisconnect.setTitleColor(UIColor.cyan, for: UIControlState.highlighted)
        btnDisconnect.addTarget(self, action: #selector(btnDisconnectPressed(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(btnDisconnect)
        
        label = UILabel(frame: CGRect(0,0,200,100))
        label.center = CGPoint(view.center.x, 300)
        label.numberOfLines = 0 //Multi-lines
        label.text = "Please Sign in to Graffiti Using Google"
        label.textColor = UIColor.cyan
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        
        label.isHidden = true
        btnDisconnect.isHidden = true

    }
    
    func getPostsByUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let user = appDelegate.currentUser {
            print("app delegate current user can be unwrapped")
            self.user = user
        } else {
            print("sadness")
        }
        
        let uId: Int = user!.getId()
        
        // make network request
        API.sharedInstance.getUserPosts(userid: uId) { response in
            switch response.result {
            case .success:
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
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count + 1
    }
    
    // create a cell for each table view row
    // would be nice to be able to reuse FeedViewController code...
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
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
            print("we here")
            // downcast cell to the custom cell class
            // guard safely unwraps the optional
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewTextCell else {
                fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
            }
            
            // this is where we get the post from the post model
            let post = posts[indexPath.row]
            
            cell.textView.text = post.getText()
            setRatingDisplay(cell: cell, post: post)
            setRatingDisplay(cell: cell, post: post)
            
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
    
    func btnSignOutPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().disconnect()
        label.text = "Disconnecting."
    }
    
    func btnDisconnectPressed(_ sender: UIButton) {
        //TODO
        //self.navigationController?.popToRootViewController(animated: true)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextviewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(nextviewController, animated: true, completion: nil)
        
        
        label.text = "Signed out."
        label.isHidden = false
        LoginViewController().toggleAuthUI()
        
    }

    
    func getFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        return formatter.timeSince(from: date as NSDate, numericDates: true)
    }

    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
