//
//  ProfileViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width

extension UIViewController {
    func addStatusBarBackgroundView(viewController: UIViewController) -> Void {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size:CGSize(width: SCREEN_WIDTH, height:20))
        let view : UIView = UIView.init(frame: rect)
        view.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1) //Replace value with your required background color
        viewController.view?.addSubview(view)
    }
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
   
    var posts: [Post] = []
    var user: User? = nil
    
    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        addStatusBarBackgroundView(viewController: self)
        
        if let user = appDelegate.currentUser {
            self.user = user
        }
        
        getPostsByUser()
        
        setupEmptyBackgroundView(withMessage: "Loading posts...")
        
        headerLabel.text = user?.getUsername()
        bioLabel.text = user?.getBio()
        profilePicture.image = user?.getImageTag()
        if(profilePicture.image == nil){
            print("Profpic was nil")
            profilePicture.image = #imageLiteral(resourceName: "cat-prof-100")
        }
        
        // self sizing table view cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        addStatusBarBackgroundView(viewController: self)
        
        if let user = appDelegate.currentUser {
            self.user = user
        }

        getPostsByUser()
        
        headerLabel.text = user?.getUsername()
        bioLabel.text = user?.getBio()
        profilePicture.image = user?.getImageTag()
        if(profilePicture.image == nil){
            print("Profpic was nil")
            profilePicture.image = #imageLiteral(resourceName: "cat-prof-100")
        }
        
        // self sizing table view cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    func showNoPostsTable() {
        setupEmptyBackgroundView(withMessage: "You haven't posted anything yet!")
        tableView.separatorStyle = .none
        tableView.backgroundView?.isHidden = false
    }
    
    func setupEmptyBackgroundView(withMessage message: String) {
        let emptyView = UIView(frame: view.bounds)
        emptyView.addSubview(label(withMessage: message))
        tableView.backgroundView = emptyView
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func setupTableViewForNumRows(_ numRows: Int) {
        if numRows == 0 {
            showNoPostsTable()
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
    }
    
    func label(withMessage text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        label.text = text
        label.textAlignment = .center
        print(view.bounds.width)
        if(view.bounds.width < 350.0){
            label.font = UIFont.systemFont(ofSize: 17)
        } else {
            label.font = UIFont.systemFont(ofSize: 20)
        }
        label.textColor = UIColor.darkGray
        label.center = CGPoint(view.center.x - g10, view.center.y - 200) // I'm sorry I'm just finnicky
        return label
    }
    
    func showAlert(messageTitle: String, message: String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoadUserAlert() {
        showAlert(messageTitle: "Load User Error", message: "There was a problem loading your profile. Please try again.")
    }
    
    func getPostsByUser() {
        
        if(user == nil){
            self.showLoadUserAlert()
            return
        }
        
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
        
        setupTableViewForNumRows(self.posts.count)
        
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
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage(sender:)))
            imageCell.feedImageView.addGestureRecognizer(tapGestureRecognizer)
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
    
}


