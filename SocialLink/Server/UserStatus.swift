//
//  UserState.swift
//  SocialLink
//
//  Created by Lê Duy on 3/27/21.
//

import Foundation

var userStatus = UserStatus()

class UserStatus {
    var user_name = ""
    func setState(userName:String) {
        self.user_name = userName
    }
}

