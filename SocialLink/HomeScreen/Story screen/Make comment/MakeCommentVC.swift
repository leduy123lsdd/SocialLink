//
//  MakeCommentVC.swift
//  SocialLink
//
//  Created by Lê Duy on 4/1/21.
//

import UIKit
import ProgressHUD
import Alertift

class MakeCommentVC: UIViewController {
    
    var post_belong_user:String=""
    
    // MARK: ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        getComments(post_id: postId!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.isNavigationBarHidden = false
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    // MARK: Outlet
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableviewToTopConstraint: NSLayoutConstraint!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var commentSection: UITextField!
    @IBOutlet var commentToBottomArea: NSLayoutConstraint!
    @IBOutlet var replyingLabel: UIView!
    @IBOutlet var replyingLabelBottonConstrain: NSLayoutConstraint!
    @IBOutlet var replyingLabelHeight: NSLayoutConstraint!
    @IBOutlet var replyingToWho: PaddingLabel!
    @IBOutlet var hideReplyingButton: UIButton!
    
    let emoji = ["❤️","👍","🔥","👏","🥺","😢","😍","😂"]
    var replyingTo:String?
    var postId:String?
    
    var commentsData = [[String:Any]]()
    // Save url of avatar from each comment in comments section
    var avatarUrls = [String]()
    var repliesData = [[String:Any]]()
    
    
    // true is it a comment, false is reply
    var isComment = true
    
    var replying_to_comment_id:String = ""
    var replying_at = 0
    
    var user_get_reply = ""
    
    // MARK: Send comment
    @IBAction func sendBtnAction(_ sender: Any) {
        
        let message = commentSection.text ?? ""
        
        if message != "" {
            if isComment {
                // Comment call server
                sendComment(message: message)
            } else {
                // Reply call server .
                sendReply(message: message, comment_id: replying_to_comment_id) { reply in
                    
                    
                    
                    // Update data to tableView
                    self.commentsData.insert(reply, at: self.replying_at + 1)
                    self.tableView.reloadData()
                }
            }
        }
        
        isHideReplyingView(true)
        commentSection.endEditing(true)
        commentSection.text = ""
    }
    
    private func sendComment(message:String){
        let uploadTime = Date().timeIntervalSince1970
        let comment_id = userStatus.user_account + "\(uploadTime)"
        
        let newComment:[String:Any] = [
            "type":"comment",
            "message":message,
            "user_account": userStatus.user_account,
            "time" : uploadTime,
            "comment_id": comment_id,
            "liked_by_users":[String]()
        ]
        
        ServerFirebase.uploadComment(post_id: self.postId!, newComment: newComment) {
            
            
            if self.post_belong_user != userStatus.user_account {
                notificationCenterServer.post_notification(user_give_notif: userStatus.user_account,
                                                           user_get_notif: self.post_belong_user,
                                                           post_id: self.postId!,
                                                           type: "comment_post")
            }
            
            self.commentsData.append(newComment)
            self.tableView.reloadData()
        }
    }
    
    // MARK: Send reply
    private func sendReply(message:String,comment_id:String,completion:@escaping(_ reply:[String:Any])->Void){
        let uploadTime = Date().timeIntervalSince1970
        let newReply:[String:Any] = [
            "comment_id":comment_id,
            "user_account":userStatus.user_account,
            "message":message,
            "time":uploadTime,
            "type":"reply",
            "reply_id":("\(userStatus.user_account)\(uploadTime)"),
            "liked_by_users":[String]()
        ]
        
        ServerFirebase.uploadReplyToComment(newReply: newReply, comment_id: comment_id) {
            
            if self.user_get_reply != userStatus.user_account && self.user_get_reply != "" {
                
                notificationCenterServer.post_notification(user_give_notif: userStatus.user_account,
                                                           user_get_notif: self.user_get_reply,
                                                           post_id: self.postId!,
                                                           type: "reply_post")
            }
            
            /**
             1: add reply to reply arr
             2: get all reply which belonging to a comment, sorte by time
             3: add that replies to comment Array
             */
            completion(newReply)
        }
    }
        
    // MARK: Setup UI
    private func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        tableView.register(UINib(nibName: "ReplyCommentCell", bundle: nil), forCellReuseIdentifier: "ReplyCommentCell")
        tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        userImage.layer.cornerRadius = 20
        commentSection.layer.masksToBounds = true
        commentSection.layer.cornerRadius = 20
        commentSection.layer.borderColor = UIColor.lightGray.cgColor
        commentSection.layer.borderWidth = 0.6
        commentSection.setLeftPaddingPoints(10)
        commentSection.setRightPaddingPoints(40)
        
        self.navigationItem.title = "Comments"
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.backBarButtonItem?.title = ""
        
        isHideReplyingView(true)
        
        userImage.sd_setImage(with: userStatus.avatarUrl, completed: nil)
    }
    
    // MARK: Get comments and get replies for comment
    private func getComments(post_id:String) {
        
        ProgressHUD.show()
        
        ServerFirebase.getComments(postId: post_id) { dataRes in
            // Assign comments
            self.commentsData = dataRes
            
            // Reload tableview to present comments
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
    }
    
    
    // MARK: close replying BUTTon Action
    @IBAction func closeReplying(_ sender: Any) {
        isHideReplyingView(true)
    }
    
    // MARK: Add emoji
    @IBAction func btn1(_ sender: Any) {
        commentSection.text! += emoji[0]
    }
    @IBAction func btn2(_ sender: Any) {
        commentSection.text! += emoji[1]
    }
    @IBAction func btn3(_ sender: Any) {
        commentSection.text! += emoji[2]
    }
    @IBAction func btn4(_ sender: Any) {
        commentSection.text! += emoji[3]
    }
    @IBAction func btn5(_ sender: Any) {
        commentSection.text! += emoji[4]
    }
    @IBAction func btn6(_ sender: Any) {
        commentSection.text! += emoji[5]
    }
    @IBAction func btn7(_ sender: Any) {
        commentSection.text! += emoji[6]
    }
    @IBAction func btn8(_ sender: Any) {
        commentSection.text! += emoji[7]
    }
}

// MARK: TableView
extension MakeCommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = commentsData[indexPath.row]
        
        // type: to distinquish between a comment or replies of comments.
        let type = comment["type"] as! String
        let message = comment["message"] as! String
        let user_account = comment["user_account"] as! String
        let avatar = comment["avatarUrl"] as? URL
        let amount_like = comment["liked_by_users"] as? [String]
        let comment_id = comment["comment_id"] as! String
        
        if type == "comment" {
            // For comments cells
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            cell.setComment(message,user_account: user_account)
            
            
            // Set and get avatar
            if let url = avatar {
                cell.avatarImage.sd_setImage(with: url, completed: nil)
            } else {
                ServerFirebase.getAvatarImageURL(user_account: user_account) { urlRes in
                    guard let url = urlRes else {return}
                    cell.avatarImage.sd_setImage(with: url, completed: nil)
                    self.commentsData[indexPath.row]["avatarUrl"] = "\(url)"
                }
            }
            
            if let hideReply = comment["hide_comment"] {
                let value = hideReply as! String
                if value == "true" {
                    cell.viewAllReplies.isHidden = true
                }
            } else {
                cell.viewAllReplies.isHidden = false
            }
            
            if let replies = comment["replies"] {
                let rep = replies as! [[String:Any]]
                if rep.count == 0 {
                    cell.viewAllReplies.isHidden = true
                }
            } else {
                ServerFirebase.getMultipReply(comment_id: comment_id) { replyArr in
                    self.commentsData[indexPath.row]["replies"] = (replyArr as! [[String:Any]])
                    self.tableView.reloadData()
                }
            }
            
            // Get reply action
            cell.viewAllRepliesAction = {
                cell.viewAllReplies.isHidden = true
                self.commentsData[indexPath.row]["hide_comment"] = "true"
                
                // Find in commentsData, clear all current reply with type = reply and commen_id equal to this comment's comment_id
                var index2 = 0
                for i in self.commentsData {
                    let id = i["comment_id"] as! String
                    let type = i["type"] as! String
                    if comment_id == id && type == "reply" {
                        self.commentsData.remove(at: index2)
                    }
                    index2 += 1
                }
                
                // Replies get from server.
                var replies = comment["replies"] as! [[String:Any]]
                var index = 0
                
                // Sort replies by time, from past to present.
                replies = replies.sorted(by: {($0["time"] as! Double) < ($1["time"] as! Double)})
                
                for rep in replies {
                    self.commentsData.insert(rep, at: indexPath.row + 1 + index)
                    index += 1
                }
                
                self.tableView.reloadData()
                
            }
            
            // Action when user clicked on reply button
            cell.replyAction = {
                self.isHideReplyingView(false)
                
                self.replyingToWho.text = "Replying to \(comment["user_account"] ?? "nil")"
                self.user_get_reply = comment["user_account"] as! String
                
                self.replying_to_comment_id = comment["comment_id"] as! String
                self.replying_at = indexPath.row
            }
            
            cell.heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.heartBtn.tintColor = UIColor.gray
            
            // Amount like
            if let likes = amount_like {
                cell.amountLikes.text = "\(likes.count) likes"
                
                if likes.count > 0 {
                    for user in likes {
                        if user == userStatus.user_account {
                            cell.heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            cell.heartBtn.tintColor = UIColor.systemPink
                            break
                        }
                    }
                } else {
                    cell.heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                    cell.heartBtn.tintColor = UIColor.gray
                }
            }
            
            cell.likeCommentAction = {
                ServerFirebase.like_unlike_comment(comment_id: comment_id, postId: self.postId!, fromUser: userStatus.user_account) { data in
                    self.commentsData[indexPath.row] = data
                    self.tableView.reloadData()
                }
            }
            
            return cell
        } else {
            // For replies cell
            let reply_id = comment["reply_id"] as! String
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCommentCell") as! ReplyCommentCell
            
            cell.commentLabel.text = comment["message"] as? String
            cell.setComment(message, user_account: user_account)
            
            // Set avatar for comments and replies
            if let url = avatar {
                cell.avatarImage.sd_setImage(with: url, completed: nil)
            } else {
                ServerFirebase.getAvatarImageURL(user_account: user_account) { urlRes in
                    guard let url = urlRes else {return}
                    cell.avatarImage.sd_setImage(with: url, completed: nil)
                    
                    self.commentsData[indexPath.row]["avatarUrl"] = "\(url)"
                }
            }
            
            cell.replyBtnAction = {
                self.isComment = false
                self.isHideReplyingView(false)
                self.replyingToWho.text = "Replying to \(comment["user_account"] ?? "nil")"
                
                self.replying_to_comment_id = comment["comment_id"] as! String
                self.replying_at = indexPath.row
            }
            
            cell.heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.heartBtn.tintColor = UIColor.gray
            
            // Amount like
            if let likes = amount_like {
                cell.amountLikes.text = "\(likes.count) likes"
                
                if likes.count > 0 {
                    for user in likes {
                        if user == userStatus.user_account {
                            cell.heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            cell.heartBtn.tintColor = UIColor.systemPink
                            break
                        }
                    }
                } else {
                    cell.heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                    cell.heartBtn.tintColor = UIColor.gray
                }
            }
            
            // Process like or unlike action of cell
            cell.likeReplyAction = {
                ServerFirebase.like_unlike_Reply(comment_id: comment_id, reply_id: reply_id, fromUser: userStatus.user_account) { dataRes in
                    self.commentsData[indexPath.row] = dataRes
                    self.tableView.reloadData()

                }
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        commentSection.endEditing(true)
    }
    
    // MARK: Swipe for delete cell action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let comment = commentsData[indexPath.row]
        
        // Owner of comment
        let user_account_comment = comment["user_account"] as! String
        // Owner of current user login
        let user_login = userStatus.user_account
        
        // Remove action
        let removeAction = UIContextualAction(style: .normal, title: "") { (action, view, actionPerformed) in
            
            let comment_type = comment["type"] as! String
            let comment_id = comment["comment_id"] as! String
            
            if comment_type == "comment" {
                Alertift.alert(title: "Confirm", message: "Delete this comment?")
                    .action(.destructive("Delete")) {
                        ServerFirebase.deleteComment(comment_id: comment_id, at: self.postId ?? "") {
                            self.commentsData.removeAll()
                            
                            self.getComments(post_id: self.postId!)
                        }
                    }
                    .action(.cancel("Cancel"))
                    .show()
            }
            
            if comment_type == "reply" {
                Alertift.alert(title: "Confirm", message: "Delete this reply?")
                    .action(.destructive("Delete")) {
                        guard let reply_id = comment["reply_id"] as? String else {return}
                        
                        ServerFirebase.deleteReply(comment_id: comment_id, reply_id: reply_id) {
                            self.commentsData.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        }
                    }
                    .action(.cancel("Cancel"))
                    .show()
            }
            
        }
        
        removeAction.backgroundColor = .red
        removeAction.image = UIImage(systemName: "trash")
        
        // Reply action
        let replyActon = UIContextualAction(style: .normal, title: "") { (action, view, actionPerformed) in
            self.isHideReplyingView(false)
            self.replyingToWho.text = "Replying to \(comment["user_account"] ?? "nil")"
            
            self.replying_to_comment_id = comment["comment_id"] as! String
            self.replying_at = indexPath.row
        }
        
        replyActon.backgroundColor = .gray
        replyActon.image = UIImage(systemName: "arrow.turn.up.left")
        
        if user_account_comment == user_login {
            // Can reply and delete comment
            return UISwipeActionsConfiguration(actions: [removeAction,replyActon])
        } else {
            // Can reply comment
            return UISwipeActionsConfiguration(actions: [replyActon])
        }
        
    }
    
    func setCell(color:UIColor, at indexPath: IndexPath){
            // I can change external things
            self.view.backgroundColor = color
            // Or more likely change something related to this cell specifically.
            let cell = tableView.cellForRow(at: indexPath )
            cell?.backgroundColor = color
        }
    
    func updateAvatarFor(cell:UITableViewCell, with url:URL) {
        let commentCell = cell as? CommentCell
        let replyCell = cell as? ReplyCommentCell
        if let comment = commentCell {
            comment.avatarImage.sd_setImage(with: url, completed: .none)
        }
        if let reply = replyCell {
            reply.avatarImage.sd_setImage(with: url, completed: .none)
        }
    }
}

// MARK: - Support functions
extension MakeCommentVC {
    
    // MARK: Find the index of item in array by id
    private func findLocationOfCommentBy(comment_id:String) -> Int {
        var index = 0
        for cmt in self.commentsData {
            if cmt["comment_id"] as! String == comment_id {
                return index
            }
            index+=1
        }
        return -1
    }
    
    // MARK: Get replies from repliesData, sorting it and add to comment which it belong.
    private func getRepliesBelongingToComment(comment_id:String ) -> [[String:Any]]{
        var replies = [[String:Any]]()
        for rep in self.repliesData {
            if rep["comment_id"]as!String == comment_id {
                replies.append(rep)
            }
        }
        replies = replies.sorted(by: {($0["time"] as! Double)>($1["time"] as! Double)})
        return replies
    }
    
    // MARK: Add replies from repliesData, sorting it and add to comment which it belong.
    private func addRepliesToComment(comment_id: String, replyArr: [[String:Any]]) {
        let commentIndex = self.findLocationOfCommentBy(comment_id: comment_id)
        
        self.commentsData[commentIndex]["replies"] = replyArr

    }
    // MARK: Hide and show keyboard
    @objc private func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            commentToBottomArea.constant = -keyboardSize.height - 10
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        commentToBottomArea.constant = -10
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Hide or show replying label, false: present, true: hide.
    private func isHideReplyingView(_ value:Bool = false){
        isComment = value
        
        if value {
            replyingLabelHeight.constant = 0
            hideReplyingButton.isHidden = true
        } else {
            replyingLabelHeight.constant = 40
            hideReplyingButton.isHidden = false
        }
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
}
