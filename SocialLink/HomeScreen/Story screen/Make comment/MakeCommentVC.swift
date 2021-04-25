//
//  MakeCommentVC.swift
//  SocialLink
//
//  Created by Lê Duy on 4/1/21.
//

import UIKit
import ProgressHUD

class MakeCommentVC: UIViewController {
    
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
            "comment_id": comment_id
        ]
        
        ServerFirebase.uploadComment(post_id: self.postId!, newComment: newComment) {
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
            "reply_id":("\(userStatus.user_account)\(uploadTime)")
        ]
        
        ServerFirebase.uploadReplyToComment(newReply: newReply, comment_id: comment_id) {
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
            
            var index = 0
            for comment in self.commentsData {
                
                
                index += 1
            }
            
            // Reload tableview to present comments
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
    }
    
    
    // MARK: close replying BUTTon Action
    @IBAction func closeReplying(_ sender: Any) {
        isHideReplyingView(true)
        isComment = true
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
    
    // MARK: Load avatar for each comments
    var user_account_filter = [[String:Any]]()
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

        
        if type == "comment" {
            // For comments cells
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            cell.setComment(message,user_account: user_account)
            
            let cmt_id = comment["comment_id"] as! String
            
            // Set avatar for comments and replies
            ServerFirebase.getAvatarImageURL(user_account: user_account) { urlRes in
                guard let url = urlRes else {return}
                cell.avatarImage.sd_setImage(with: url, completed: nil)
            }
            
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
            
            // Get reply action
            cell.viewAllRepliesAction = {
                
                cell.viewAllReplies.isHidden = true
                
                ServerFirebase.getReply(comment_id: cmt_id) { replyArr in
                    let comment_id = comment["comment_id"] as! String
                    
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
                    var replies = (replyArr as! [[String:Any]])
                    var index = 0
                    
                    // Sort replies by time, from past to present.
                    replies = replies.sorted(by: {($0["time"] as! Double) < ($1["time"] as! Double)})
                    
                    for rep in replies {
                        self.commentsData.insert(rep, at: indexPath.row + 1 + index)
                        index += 1
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            // Action when user clicked on reply button
            cell.replyAction = {
                self.isComment = false
                self.isHideReplyingView(false)
                self.replyingToWho.text = "Replying to \(comment["user_account"] ?? "nil")"
                
                self.replying_to_comment_id = comment["comment_id"] as! String
                self.replying_at = indexPath.row
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
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        commentSection.endEditing(true)
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
        if value {
            self.replyingLabelHeight.constant = 0
            hideReplyingButton.isHidden = true
        } else {
            self.replyingLabelHeight.constant = 40
            hideReplyingButton.isHidden = false
        }
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
}
