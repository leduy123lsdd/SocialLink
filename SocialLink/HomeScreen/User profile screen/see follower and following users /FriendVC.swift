//
//  FriendVC.swift
//  SocialLink
//
//  Created by Lê Duy on 5/22/21.
//

import UIKit
import SDWebImage

struct Friend {
    var name:String
    init(name:String) {
        self.name = name
    }
}



class FriendVC: UIViewController {
    
    public func fetchDataFor(user_account:String) {
        ServerFirebase.getUserProfile(user_account: user_account) { (datares) in
            
            
            guard let data = datares else {return}
            
            let followers = data["followers"] as! [String]
            let  following = data["following"] as! [String]
            
            
            var returnFollowers = [Friend]()
            var returnFollowing = [Friend]()
            
            for fol in followers {
                let friend = Friend(name: fol)
                returnFollowers.append(friend)
            }
            
            for fol in following {
                let friend = Friend(name: fol)
                returnFollowing.append(friend)
            }

            self.followersData = returnFollowers
            self.followingData = returnFollowing
            
            self.changeSelectedLayoutForBtn(followers: true)
            
        }
    }
    
    
    var rootVC:UIViewController?
    @IBOutlet var followersBtn: UIButton!
    @IBOutlet var followingsBtn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    var friendsData = [Friend]()
    
    var followersData = [Friend]()
    var followingData = [Friend]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // init btn view
        changeSelectedLayoutForBtn(followers: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        rootVC?.navigationController?.isToolbarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        rootVC?.navigationController?.isToolbarHidden = true
    }
    
    
    @IBAction func followersBtnAction(_ sender: Any) {
        changeSelectedLayoutForBtn(followers: true)
    }
    
    @IBAction func followingsBtnAction(_ sender: Any) {
        changeSelectedLayoutForBtn(followings: true)
    }
    
    private func setupUI(){
        [followingsBtn,followersBtn].forEach { (btn) in
            btn?.layer.borderWidth = 0.6
            btn?.layer.borderColor = UIColor.white.cgColor
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FriendCells", bundle: nil), forCellReuseIdentifier: "FriendCells")
    }

    private func changeSelectedLayoutForBtn(followers:Bool = false, followings:Bool=false){
        if followers {
            followersBtn.backgroundColor = UIColor.link
            followersBtn.tintColor = UIColor.white
            friendsData = self.followersData
            tableView.reloadData()
        } else {
            followersBtn.backgroundColor = UIColor.white
            followersBtn.tintColor = UIColor.gray
            friendsData = self.followingData
        }
        
        
        if followings {
            followingsBtn.backgroundColor = UIColor.link
            followingsBtn.tintColor = UIColor.white
            friendsData = self.followingData
            tableView.reloadData()
        } else {
            followingsBtn.backgroundColor = UIColor.white
            followingsBtn.tintColor = UIColor.gray
            friendsData = self.followersData
        }
    }
}

extension FriendVC: UITableViewDelegate,
                    UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellData = friendsData[indexPath.row]
        let name = cellData.name
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCells") as! FriendCells
        
        ServerFirebase.getAvatarImageURL(user_account: name) { (url) in
            if let URL = url {
                
                let imageUI = UIImageView()
                imageUI.sd_setImage(with: URL, completed: nil)
                cell.parseData(avatar: imageUI.image ?? UIImage(systemName: "person")!, name: name)
                
            }
        }
        
        return cell
    }
    
    
}
