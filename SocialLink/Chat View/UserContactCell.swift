//
//  UserContactCell.swift
//  SocialLink
//
//  Created by Lê Duy on 5/24/21.
//

import UIKit

class UserContactCell: UITableViewCell {
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var displayName: UILabel!
    @IBOutlet var user_account: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func parseData(displayName:String,
                          user_account:String,
                          avatar:UIImage){
        self.avatar.image = avatar
        self.displayName.text = displayName
        self.user_account.text = user_account
    }
    
    private func setupUI(){
        avatar.layer.cornerRadius = 35
    }
    
}
