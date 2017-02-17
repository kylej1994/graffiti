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
    
    //TODO: handle rating... need to somehow identify the post corresponding to the button pressed
    // api.voteOnPost(postid: 1234, vote: 1)
    
    func refreshFeed(sender: UIRefreshControl) {
        // make a network request
        // update posts array
        print("we will refresh here")
        getPostsByLocation()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
        timestamp = self.formattedTimestamp
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
