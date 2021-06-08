//
//  UserProfileVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit
import ProgressHUD

class UserProfileVC: UIViewController {
    typealias FirebaseData = [String:Any]
    
    var rootView:UIViewController?
    
    
    @IBOutlet var dongThoiGianView: DongThoiGianView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var displayName: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var editProfileBtn: UIButton!
    @IBOutlet var messageBtn: UIButton!
    @IBOutlet var followBtn: UIButton!
    @IBOutlet var unFollowBtn: UIButton!
    @IBOutlet var avatarImage: UIImageView!
    
    @IBOutlet var postCount: UILabel!
    @IBOutlet var followersCount: UILabel!
    @IBOutlet var followingCount: UILabel!
    @IBOutlet var descriptionInfo: UITextView!
    @IBOutlet var descriptionLabel: PaddingLabel!
    @IBOutlet var backBtn: UIButton!
    

    @IBOutlet var scrollView: UIScrollView!
    private let refreshControl = UIRefreshControl()
    
    
    @IBOutlet var noPostLb: PaddingLabel!
    let friendVC = FriendVC(nibName: "FriendVC", bundle: nil)
    
    var postData = [[String:Any]]() {
        didSet {
            if postData.count == 0 {
                noPostLb.isHidden = false
            } else {
                noPostLb.isHidden = true
            }
            
            let cellWidth = (self.view.frame.width-6) / 3
            let collumn = Int(postData.count/3)
            
            if postData.count%3 != 0 {
                
                self.collectionViewHeight.constant = CGFloat(collumn + 1)*cellWidth
            } else {
                self.collectionViewHeight.constant = CGFloat(collumn)*cellWidth
            }
            
            postData = postData.sorted(by: {($0["time"] as! Double) > ($1["time"] as! Double)})
        }
    }
    var user_account = ""
    let stories = StoriesVC(nibName: "StoriesVC", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        friendVC.rootVC = rootView
        
        // Setup for stories VC
        stories.rootVC = self.rootView
        
        postData.removeAll()
        dongThoiGianView.storyData.removeAll()
        
        noPostLb.isHidden = true
        fetchDataFor(user_account: self.user_account, completion: nil)
        updatePost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        collectionView.reloadData()
        navigationController?.isNavigationBarHidden = true
        
        // Check condition for hide or show btns (edit profile, follow, message). Hide follow, message btn if user profile is from current user. Whereas hide edit profile.
        if user_account == userStatus.user_account {
            // Hide follow and message btn.
            messageBtn.isHidden = true
            followBtn.isHidden = true
            unFollowBtn.isHidden = true
        } else {
            editProfileBtn.isHidden = true
            messageBtn.isHidden = false
        }
        
        if self.postData.count == 0 {
            noPostLb.isHidden = false
            collectionViewHeight.constant = 0
        } else {
            noPostLb.isHidden = true
        }
    }
    
    // MARK: - update post accorrding changes in posts data
    
    // MARK: setup UI for view
    private func setupUI(){
        self.nameLabel.text = user_account
        self.displayName.text = userStatus.display_name
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PostImageCell", bundle: nil), forCellWithReuseIdentifier: "PostImageCell")
        collectionView.isScrollEnabled = false
        
        [editProfileBtn,messageBtn,unFollowBtn].forEach { btn in
            btn?.layer.borderWidth = 0.6
            btn?.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        descriptionInfo.sizeToFit()
        descriptionInfo.isScrollEnabled = false
        descriptionInfo.isUserInteractionEnabled = false
        
        dongThoiGianView.rootVC = self.rootView
        
        dongThoiGianView.parseData(user_account: self.user_account)
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc private func refreshData(){
        refreshControl.beginRefreshing()
        
        self.updatePost()
        self.fetchDataFor(user_account: self.user_account, completion: nil)
        
        self.dongThoiGianView.parseData(user_account: self.user_account)
    }
    
    // MARK: Fetch data for user
    func fetchDataFor(user_account:String, completion:(()->Void)?) {
        // Get avatar
        ServerFirebase.getAvatarImageURL(user_account: user_account) { urlRes in
            if let url = urlRes {
                self.avatarImage.sd_setImage(with: url, completed: nil)
            }
        }
    
        ServerFirebase.getUserProfile(user_account: user_account) { res in
            self.refreshControl.endRefreshing()
            if let response = res {
                if let followers = response["followers"],
                   let followers_arr = followers as? [String] {
                    
                    self.followersCount.text = "\(followers_arr.count)"
                    
                    if self.user_account != userStatus.user_account {
                        var followed = false
                        for follower in followers_arr {
                            if follower == userStatus.user_account {
                                followed = true
                                break
                            }
                        }
                        
                        if followed {
                            self.followBtn.isHidden = true
                            self.unFollowBtn.isHidden = false
                        } else {
                            self.followBtn.isHidden = false
                            self.unFollowBtn.isHidden = true
                        }
                    }
                    
                }
                
                if let following = response["following"],
                   let following_arr = following as? [String]{
                    
                    self.followingCount.text = "\(following_arr.count)"
                }
                
                if let posted = response["posted_id"] as? [String] {
                    self.postCount.text = ("\(posted.count)")
                }
                
                if let bio = response["bio"] as? String {
                    self.descriptionInfo.text = bio
                    
                    if bio == "" {
                        self.descriptionInfo.isHidden = true
                        self.descriptionLabel.isHidden = true
                    } else {
                        self.descriptionInfo.text = bio
                        self.descriptionLabel.isHidden = false
                        self.descriptionInfo.sizeToFit()
                    }
                }
                
            }
        }

    }
    
    
    private func updatePost(completion:(()->Void)? = nil){
        postData.removeAll()
        ServerFirebase.getUserPost(user_account: self.user_account) { data in
            self.refreshControl.endRefreshing()
            let newPost = data["post_id"] as! String
            var existed = false

            for post in self.postData {
                let post = post["post_id"] as! String
                if post == newPost {
                    existed = true
                    break
                }
            }

            if !existed {
                self.postData.append(data)
                
                self.collectionView.reloadData()
            }
            
            
        } failed: {
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    // MARK: Following, followers and post count action

    @IBAction func postAction(_ sender: Any) {
        print("post clicked")
    }
    
    @IBAction func followerAction(_ sender: Any) {
        if nameLabel.text == userStatus.user_account {
            friendVC.fetchDataFor(user_account: userStatus.user_account)
            self.present(friendVC, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func followingAction(_ sender: Any) {
        if nameLabel.text == userStatus.user_account {
            friendVC.fetchDataFor(user_account: userStatus.user_account)
            self.present(friendVC, animated: true, completion: nil)
            
        }
    }
    
    // MARK: Edit profile button clicked
    @IBAction func editProfile(_ sender: Any) {
        // Present edit profile view
        let editProfileVC = EditProfileVC(nibName: "EditProfileVC", bundle: nil)
        
        editProfileVC.rootView = self
        
        editProfileVC.reloadUserInfo = {
            self.fetchDataFor(user_account: self.user_account, completion: nil)
        }
        self.rootView?.navigationController?.pushViewController(editProfileVC, animated: true)

    }
    
    @IBAction func backBtn(_ sender: Any) {
        if let navi = self.navigationController {
            navi.popToViewController(rootView!, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func followBtnAction(_ sender: Any) {
        
        ProgressHUD.show()
        
        searchUserService.followUser(follow_user: self.user_account,
                                   current_user: userStatus.user_account) {
            ProgressHUD.dismiss()
            self.followBtn.isHidden = true
            self.unFollowBtn.isHidden = false
        }
    }
    
    @IBAction func unFollowBtnAction(_ sender: Any) {
        
        ProgressHUD.show()
        
        searchUserService.unfollow(follow_user: self.user_account,
                                   current_user: userStatus.user_account) {
            ProgressHUD.dismiss()
            self.followBtn.isHidden = false
            self.unFollowBtn.isHidden = true
        }
    }
    
    @IBAction func messageBtnAction(_ sender: Any) {
        
        let user1 = userStatus.user_account
        let user2 = self.user_account
        let mss = MessagesVC(nibName: "MessagesVC", bundle: nil)
        
        messageServer.findChatRoomForUsers(user1: user1, user2: user2) { (chatRoomFound) in
            if let chatRoom_id = chatRoomFound {
                
                mss.currentSenderUser = Sender(senderId: user1, displayName: user1)
                mss.chatRoom_id = chatRoom_id
                
                if user1 != userStatus.user_account {
                    mss.sender2 = Sender(senderId: user1, displayName: user1)
                } else {
                    mss.sender2 = Sender(senderId: user2, displayName: user2)
                }
                
                self.present(mss, animated: true, completion: nil)
                
            } else {
                
                messageServer.makeNewChatRoom(user1: user1, user2: user2) { chatRoom_id in
                    mss.currentSenderUser = Sender(senderId: user1, displayName: user1)
                    mss.chatRoom_id = chatRoom_id
                    
                    if user1 != userStatus.user_account {
                        mss.sender2 = Sender(senderId: user1, displayName: user1)
                    } else {
                        mss.sender2 = Sender(senderId: user2, displayName: user2)
                    }
                    
                    self.present(mss, animated: true, completion: nil)
                }
                
            }
        }
        
        
        
        
    }
    
}

// MARK: Collection View extension
extension UserProfileVC:UICollectionViewDelegate,
                        UICollectionViewDataSource,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return postData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Data for present of this cell
        let data = postData[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCell", for: indexPath) as!
            PostImageCell
        
        // Present first image of post
        if let images_url = data["images_url"] as? [URL] {
            cell.postImage.sd_setImage(with: images_url[0], completed: nil)
        }
        
        cell.tapIntoImage = { [self] in
            
            
            self.stories.scrollToPost = {
                self.stories.postData = self.postData
                self.stories.tableView.reloadData()
                self.stories.tableView.scrollToRow(at: indexPath,
                                                   at: .top,
                                                   animated: false)
            }
            
            self.stories.user = self.user_account
            
            self.rootView?.navigationController?.pushViewController(stories,
                                                                    animated: true)
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (self.view.frame.width-6) / 3
        return CGSize(width: cellWidth, height: cellWidth)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
}

