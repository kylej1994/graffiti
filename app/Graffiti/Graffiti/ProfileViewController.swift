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
    var profilePicture:UIImage? = nil
    var userName:String? = nil
    
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset.top = 20
        
        getPostsByUser()
    }
    
    func getPostsByUser() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let someuser = appDelegate.currentUser {self.user = someuser}
        
        let uId: Int = user!.getId()
        
        // make network request
        API.sharedInstance.getUserPosts(userid: uId) { response in
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
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count + 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell:HeaderCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HeaderCell
            
            userName = user!.getUsername()!
            
            profilePicture = user!.getUserImage()
        
            cell.myView.backgroundColor = UIColor(patternImage: self.profilePicture!)
            cell.myCellLabel.text = self.userName
        
            return cell
        } else {
            let cellIdentifier = "FeedCell"
            
            // downcast cell to the custom cell class
            // guard safely unwraps the optional
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewTextCell else {
                fatalError("The dequeue cell is not an instance of FeedTableViewTextCell.")
            }
            
            // this is where we get the post from the post model
            let post = posts[indexPath.row]
            let rating = post.getRating()
            
            cell.textView.text = post.getText()
            cell.votesLabel.text = String(rating)
            
            //cell.dateLabel.text = post.getTimeAdded()
            
            return cell
        }
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
