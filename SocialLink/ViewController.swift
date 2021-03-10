//
//  ViewController.swift
//  SocialLink
//
//  Created by Lê Duy on 3/7/21.
//

import UIKit
import NotificationBannerSwift
import Alamofire

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = "http://127.0.0.1:3000/test"
        
        DataRequest().from(url, dataType: [Post].self) { (data) in
            for item in data {
                print(item.title)
            }
        }
    }
    
}


