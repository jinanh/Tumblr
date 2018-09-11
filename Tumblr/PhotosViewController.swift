//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Jinan Huang on 9/6/18.
//  Copyright © 2018 Jinan Huang. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    var posts: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    var isMoreDataLoading = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.delegate = self
        fetchPosts()
        
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchPosts()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading){
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                fetchPosts()
            }
        }
    }
    
    func displayAlert(){
        let alertController = UIAlertController(title: "Can't Find Photos", message: "Check Internet Connection", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in // create a cancel button
            // handle cancel button, when click on the button masssge will dismiss
        }
        // add the cancel button to the alertController
        alertController.addAction(cancelAction)
        
        // create an OK button
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle ok button, when click on the button masssge will dismiss
        }
        // add the OK button to the alert controller
        alertController.addAction(OKAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func fetchPosts() {
        // Network request snippet
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task : URLSessionDataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            self.isMoreDataLoading = false
            
            if let error = error {
                self.displayAlert()
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(dataDictionary)
                
                // TODO: Get the posts and store in posts property
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                // TODO: Reload the table view
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexpath: IndexPath) {
        tableView.deselectRow(at: indexpath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        if let photos = post["photos"] as? [[String: Any]] {
            // photos is NOT nil, we can use it!
            // TODO: Get the photo url
            // 1.
            let photo = photos[0]
            // 2.
            let originalSize = photo["original_size"] as! [String: Any]
            // 3.
            let urlString = originalSize["url"] as! String
            // 4.
            let url = URL(string: urlString)
            
            cell.postImageView.af_setImage(withURL: url!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as!   PhotoDetailsViewController
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let post = posts[indexPath.row]
        vc.post = post
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
