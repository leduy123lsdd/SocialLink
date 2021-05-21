//
//  NotificationVC.swift
//  SocialLink
//
//  Created by Lê Duy on 5/21/21.
//

import UIKit
import SDWebImage

class NotificationVC: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var notification_data = [[String:Any]]()
    var updateNotReadNotification:((_ amount: Int)->Void)?
    var homeVC:HomeViewController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshNotificationData), for: .valueChanged)
        
        
        
    }
    @objc private func refreshNotificationData(){
        getNewData(reload: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNewData(reload: true)
    }
    
    private func getNewData(reload:Bool = false){
        
        refreshControl.beginRefreshing()
        notificationCenterServer.get_notification(user_account: userStatus.user_account) { (dataRes) in
            self.notification_data = dataRes
            self.notification_data = self.notification_data.sorted(by: {
                
                (($0["time"] as! NSString).doubleValue) > (($1["time"] as! NSString).doubleValue)
                
            })
            var index = 0
            for nof in dataRes {
                let seen_indicatior = nof["seen"] as! String
                if seen_indicatior == "false" {
                   index += 1
                }
            }

            self.homeVC?.notReadLb.text = "\(index)"
            
            
            if reload {
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
        } failed: {
            self.refreshControl.endRefreshing()
        }
        
    }


}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification_data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = notification_data[indexPath.row]
        let type = data["type"] as! String
        let user_make_notification = data["user_like"] as! String
        
        let user_get_notification = data["user_get_notif"] as! String
        let seen_indicatior = data["seen"] as! String
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        
        if seen_indicatior == "false" {
            
            cell.backgroundColorView.isHidden = false
        }
        
        if seen_indicatior == "true" {
            cell.backgroundColorView.isHidden = true
        }
        
        
        ServerFirebase.getAvatarImageURL(user_account: user_make_notification) { (url) in
            if let url = url {
                cell.avatar.sd_setImage(with: url, completed: nil)
            }
        }
        if type == "like_post" {
            cell.messageLb.text = "\(user_make_notification) đã thích bài viết của bạn."
        }
        if type == "comment_post" {
            cell.messageLb.text = "\(user_make_notification) đã bình luận về bài viết của bạn."
        }
        if type == "reply_post" {
            cell.messageLb.text = "\(user_make_notification) đã trả lời về comment của bạn."
        }
        if type == "new_post" {
            cell.messageLb.text = "\(user_make_notification) đã đăng một bài viết mới."
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = notification_data[indexPath.row]
        let user_make_notification = data["user_like"] as! String
        let user_get_notification = data["user_get_notif"] as! String
        let notif_id = data["notif_id"] as! String
        let post_id = data["post_id"] as! String
        
        notificationCenterServer.seen_post_notifi(notif_id: notif_id,
                                                  user_give_like: user_make_notification,
                                                  user_get_like: user_get_notification,
                                                  post_id: post_id) {
            
            self.getNewData(reload: true)
        }
        
        ServerFirebase.getPostBy_post_id(post_id: post_id) { (datares) in
            let stories = StoriesVC(nibName: "StoriesVC", bundle: nil)
            stories.postData = [datares]
            stories.rootVC = self.homeVC
            self.homeVC?.navigationController?.pushViewController(stories, animated: true)
        }
        
        
    }
    
}
