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
    
    var doubleTapIndicatorDisappear:(()->Void)?
    var doubleTapIndicatorAappear:(()->Void)?
    
    var deletedPost:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getPost()
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        doubleTapIndicatorDisappear?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doubleTapIndicatorAappear?()
        
    }
    
    // MARK: Fetch posts from friends or yours
    private func getPost(){
        
        refreshControl.beginRefreshing()
        
        
        searchUserService.getFollowingFriends(user_account: userStatus.user_account) { (friends) in
            if friends.count == 0 {
                self.refreshControl.endRefreshing()
                
                return
            }
            friends.forEach { (friend) in
                ServerFirebase.getUserPost(user_account: friend) { data in
                    var existed = false
                    
                    for post in self.postData {
                        if (post["post_id"] as! String) == (data["post_id"] as! String) {
                            existed = true
                            break
                        }
                    }
                    
                    if !existed {
                        self.postData.append(data)
                        self.postData.shuffle()
                        self.tableView.reloadData()
                        
                    }
                    
                    self.refreshControl.endRefreshing()
                    
                } failed: {
                    self.refreshControl.endRefreshing()
                    
                }
            }
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
        tableView.register(UINib(nibName: "NoPostTableViewCell", bundle: nil), forCellReuseIdentifier: "NoPostTableViewCell")
        
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(){
        getPost()
    }
    
}

extension StoryVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if postData.count == 0 {
            return 2
        }
        return postData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Story
        if indexPath.row == 0 {
            tableView.rowHeight = 100
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubStoryCell") as! SubStoryCell
            cell.rootVC = self.rootVC
            
            return cell
        }
        if indexPath.row == 1 && postData.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPostTableViewCell") as! NoPostTableViewCell
            tableView.rowHeight = 200
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
        
        cell.deletedPost = {
            self.dismiss(animated: true, completion: nil)
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
                "post_id": data["post_id"]!,
                "get_like_user":data["user_account"] as! String
            ]) { (res) in
                self.postData[indexPath.row - 1]["liked_by_users"] = res
                let newData = self.postData[indexPath.row - 1]["liked_by_users"] as! [Any]
                cell.likes.text = "❤️ \(newData.count) Likes"
            }
            
        }
        return cell
        
    }
    
}
