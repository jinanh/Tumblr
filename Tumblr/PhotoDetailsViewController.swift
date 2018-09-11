//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Jinan Huang on 9/10/18.
//  Copyright © 2018 Jinan Huang. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    
    var post: [String: Any]!
    
    override func viewDidLoad() {
        
     if let photos = post ["photos"] as? [[String: Any]] {
        let photo = photos[0]
        let originalSize = photo["original_size"] as! [String: Any]
        let urlString = originalSize["url"] as! String
        let url = URL(string: urlString)
        photoView.af_setImage(withURL: url!)

        // Do any additional setup after loading the view.
    }
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
