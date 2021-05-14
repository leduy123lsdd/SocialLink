//
//  UserState.swift
//  SocialLink
//
//  Created by Lê Duy on 3/27/21.
//

import Foundation

var userStatus = UserStatus()

class UserStatus {
    
    var user_account = ""
    var display_name = ""
    var amount_post = 0
    var followers = 0
    var following = 0
    var posted_id = [String]()
    var avatarUrl:URL?
    var bio = ""
    
    init() {}
    
    init(info_data:[String:Any]) {
        self.user_account = info_data["user_account"] as! String
        
        self.display_name = info_data["display_name"] as! String
        self.amount_post = info_data["amount_post"] as! Int
//        self.followers = info_data["followers"] as! Int
//        self.following = info_data["following"] as! Int
        self.posted_id = info_data["posted_id"] as! [String]
        self.bio = info_data["bio"] as! String
        
        ServerFirebase.getAvatarImageURL(user_account: self.user_account) { urlRes in
            guard let url = urlRes else {return}
            self.avatarUrl = url
        }
    }
}

