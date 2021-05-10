//
//  StoriesVC.swift
//  SocialLink
//
//  Created by Lê Duy on 4/25/21.
//

import UIKit
import ProgressHUD

class StoriesVC: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
//    @IBOutlet var userAccountLabel: UILabel!
    
    var rootVC:UIViewController?
    var postData = [[String:Any]]() {
        didSet {
            postData = postData.sorted(by: {($0["time"] as! Double) > ($1["time"] as! Double)})
        }
    }
    
    var user:String?
    var scrollToPost:(()->Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainContentCell", bundle: nil), forCellReuseIdentifier: "MainContentCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
        
        
        self.navigationItem.title = user
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.backBarButtonItem?.title = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.isNavigationBarHidden = false
        
        if let scrollAction = scrollToPost {
            scrollAction()
        }
        
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        rootVC?.navigationController?.popViewController(animated: true)
    }
    
}

extension StoriesVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postData.count
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Posts
        
        let data = postData[indexPath.row]
        let post_id = data["post_id"] as! String
        let liked_user = data["liked_by_users"] as! [String]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainContentCell") as! MainContentCell
        cell.rootVC = self.rootVC
        cell.parseData(data: data)
        
        // Get amount of comments
        ServerFirebase.getComments(postId: post_id) { data in
            cell.comments.text = "\(data.count) Comments"
        }
        
        // Change like button icon
        cell.liked = false
        for user_like in liked_user {
            if userStatus.user_account == user_like {
                cell.liked = true
                break
            }
            
        }
        
        // Action when click into like butotn
        cell.likeClicked = {
            cell.liked = !cell.liked
            
            ServerFirebase.newLike(from: [
                "user_account":userStatus.user_account,
                "post_id": data["post_id"]!
            ]) { (res) in
                self.postData[indexPath.row - 1]["liked_by_users"] = res
                let newData = self.postData[indexPath.row - 1]["liked_by_users"] as! [Any]
                cell.likes.text = "❤️ \(newData.count) Likes"
            }
            
        }
        return cell
    }
}
