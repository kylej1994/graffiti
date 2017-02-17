//
//  ProfileViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UITableViewController {
    
    let api = API.sharedInstance
    let locationManager = LocationService.sharedInstance
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func getPostsByUser() {
        // make network request
        
        /*
        api.getPosts(userid: currUserID) { response in
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
         */
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = posts.count
        if numRows == 0 {
            //setupEmptyBackgroundView()
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
        
        // this is where we get the posts from the post model
        let post = posts[indexPath.row]
        cell.textView.text = post.getText()
        cell.votesLabel.text = "\(post.getRating())" // this might be a bad practice'
        
        //cell.dateLabel.text = post.getTimeAdded()
        
        cell.voteTapAction = { (cell) in
            print("upvote tapped!")
            print(tableView.indexPath(for: cell)!.row)
        }
        return cell
    }

}
