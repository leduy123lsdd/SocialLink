//
//  UserProfileVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit
//import FirebaseUI
import Firebase

class UserProfileVC: UIViewController {
    typealias FirebaseData = [String:Any]
    
    var rootView:UIViewController?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var displayName: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var editProfileBtn: UIButton!
    @IBOutlet var messageBtn: UIButton!
    @IBOutlet var followBtn: UIButton!
    @IBOutlet var avatarImage: UIImageView!
    
    @IBOutlet var postCount: UILabel!
    @IBOutlet var followersCount: UILabel!
    @IBOutlet var followingCount: UILabel!
    
    
    @IBOutlet var descriptionInfo: UITextView!
    
//    var images = [UIImage]()
    let storyData = ["doc","cat","bird","mouse","banana","mango"]
    var postData = [[String:Any]]() {
        didSet {
            let cellWidth = (self.view.frame.width-6) / 3
            let collumn = Int(postData.count/3)
            
            if postData.count%3 != 0 {
                
                self.collectionViewHeight.constant = CGFloat(collumn + 1)*cellWidth
            } else {
                self.collectionViewHeight.constant = CGFloat(collumn)*cellWidth
            }
        }
    }
    var user_account = ""
    let stories = StoriesVC(nibName: "StoriesVC", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        // Check condition for hide or show btns (edit profile, follow, message). Hide follow, message btn if user profile is from current user. Whereas hide edit profile.
        if user_account == userStatus.user_account {
            // Hide follow and message btn.
            messageBtn.isHidden = true
            followBtn.isHidden = true
        } else {
            editProfileBtn.isHidden = true
        }
        
        // Setup for stories VC
        stories.rootVC = self.rootView
        stories.getPost(for: userStatus.user_account)
        
        postData.removeAll()
        
        fetchDataFor(user_account: self.user_account, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
    
    // MARK: setup UI for view
    private func setupUI(){
        self.nameLabel.text = userStatus.user_account
        self.displayName.text = userStatus.display_name
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PostImageCell", bundle: nil), forCellWithReuseIdentifier: "PostImageCell")
        collectionView.isScrollEnabled = false
        
        [editProfileBtn,messageBtn].forEach { btn in
            btn?.layer.borderWidth = 0.6
            btn?.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        // Config for description text field
        descriptionInfo.translatesAutoresizingMaskIntoConstraints = true
        descriptionInfo.sizeToFit()
        descriptionInfo.isScrollEnabled = false
    }
    
    // MARK: Fetch data for user
    func fetchDataFor(user_account:String, completion:(()->Void)?) {
        // Get avatar
        ServerFirebase.getAvatarImageURL(user_account: userStatus.user_account) { urlRes in
            if let url = urlRes {
                self.avatarImage.sd_setImage(with: url, completed: nil)
            }
        }
    
        ServerFirebase.getUserProfile(user_account: user_account) { res in
            if let response = res {
                if let followers = response["followers"] {
                    self.followersCount.text = "\(followers)"
                }
                if let following = response["following"] {
                    self.followingCount.text = "\(following)"
                }
                if let posted = response["posted_id"] as? [String] {
                    self.postCount.text = ("\(posted.count)")
                }
                
            }
        }
        
        // Get post data
        ServerFirebase.getUserPost(user_account: userStatus.user_account) { data in
            self.postData.append(data)
            self.collectionView.reloadData()
        } failed: {}
    }
    
    
    // MARK: Following, followers and post count action

    @IBAction func postAction(_ sender: Any) {
        print("post clicked")
    }
    
    @IBAction func followerAction(_ sender: Any) {
        print("follower clicked")
    }
    
    @IBAction func followingAction(_ sender: Any) {
        print("following clicked")
    }
    
    // MARK: Edit profile button clicked
    @IBAction func editProfile(_ sender: Any) {
        // Present edit profile view
        let editProfileVC = EditProfileVC(nibName: "EditProfileVC", bundle: nil)
        editProfileVC.rootView = self
        self.dismiss(animated: true) {
            self.rootView?.navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    
    @IBAction func followBtnAction(_ sender: Any) {
        
    }
    
    @IBAction func messageBtnAction(_ sender: Any) {
        
    }
}

// MARK: Collection View extension
extension UserProfileVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCell", for: indexPath) as!
            PostImageCell
//        cell.setImage(imageData: images[indexPath.row])
        cell.tapIntoImage = { [self] in
            print(indexPath.row)
            
            self.stories.scrollToPost = {
                self.stories.tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: false)
            }
            
            self.rootView?.navigationController?.pushViewController(stories, animated: true)
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (self.view.frame.width-6) / 3
        return CGSize(width: cellWidth, height: cellWidth)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
