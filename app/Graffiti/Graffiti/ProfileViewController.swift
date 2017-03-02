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
    
    //~~//
    let offset_HeaderStop:CGFloat = 60.0 // At this offset the Header stops its transformations
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
        super.viewDidAppear(animated)
        getPostsByUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.contentInset.top = 20
        self.edgesForExtendedLayout = [];
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;
        
        addStatusBarBackgroundView(viewController: self)
        
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
        
        // PULL DOWN -----------------
        
        // Header -----------
        
        headerTransform = CATransform3DTranslate(headerTransform, 0, -offset, 0)
        
        // Table View -----------
        
        if(offset < 150.0){
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
            
            tableViewTransform = CATransform3DTranslate(tableViewTransform, 0, -offset, 0)
            if(offset > 0.0){
                tableView.frame.size = CGSize(tableView.contentSize.width, height - offset + 80) //and vice versa when keyboard is dismissed
            }
            print("bounds: " + String(describing: bounds))
            print("height: " + String(describing: height))
            print("height+offset: " + String(describing: (height-offset)))
            
            if(tableView.frame.height > height){
                //tableView.frame.size = CGSize(tableView.contentSize.width, height + offset)
                print("when am I here?")
            }
            
            
        } else {
            //print("oh hey")
            tableViewTransform = CATransform3DTranslate(tableViewTransform, 0, -150, 0)
            
        }
        // Avatar -----------
            
        var avatarScaleFactor = (min(offset_HeaderStop, offset)) / profilePicture.bounds.height / 0.8 // Slow down the animation
        if(avatarScaleFactor < -0.25){
            avatarScaleFactor = -0.25
        }
        let avatarSizeVariation = ((profilePicture.bounds.height * (1.0 + avatarScaleFactor)) - profilePicture.bounds.height) / 1.4
        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
        if offset <= offset_HeaderStop {
            if profilePicture.layer.zPosition < header.layer.zPosition{
                header.layer.zPosition = 0
            }
            
        }else {
            if profilePicture.layer.zPosition >= header.layer.zPosition{
                header.layer.zPosition = 0
            }
        }
        
        tableView.layer.transform = tableViewTransform
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


