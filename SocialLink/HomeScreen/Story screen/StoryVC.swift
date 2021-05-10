//
//  StoryVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit

class StoryVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var postData = [[String:Any]]()
    var rootVC:UIViewController?
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getPost()
    }
    
    // MARK: Fetch posts from friends or yours
    private func getPost(){
        refreshControl.beginRefreshing()
        ServerFirebase.getUserPost(user_account: userStatus.user_account) { data in
            var existed = false
            
            for post in self.postData {
                if (post["post_id"] as! String) == (data["post_id"] as! String) {
                    existed = true
                    break
                }
            }
            
            if !existed {
                self.postData.append(data)
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
            
        } failed: {
            self.refreshControl.endRefreshing()
            
        }
    }
    
    // MARK: Scroll to top
    func scrollToTop(){
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    // MARK: setup UI
    private func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SubStoryCell", bundle: nil), forCellReuseIdentifier: "SubStoryCell")
        tableView.register(UINib(nibName: "MainContentCell", bundle: nil), forCellReuseIdentifier: "MainContentCell")
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(){
        getPost()
    }
    
}

extension StoryVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Story
        if indexPath.row == 0 {
            tableView.rowHeight = 100
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubStoryCell") as! SubStoryCell
            return cell
        }
        
        // Posts
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
        
        let data = postData[indexPath.row - 1]
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
