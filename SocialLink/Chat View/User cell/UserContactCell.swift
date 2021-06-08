//
//  UserContactCell.swift
//  SocialLink
//
//  Created by Lê Duy on 5/24/21.
//

import UIKit

class UserContactCell: UITableViewCell {
    
    @IBOutlet var avatar: UIImageView!

    @IBOutlet var user_account: UILabel!
    
    
    @IBOutlet weak var lastText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        avatar.layer.cornerRadius = 35
        selectionStyle = .none
    }
    
    public func parseData(displayName:String,
                          user_account:String,
                          avatar:UIImage){
        self.avatar.image = avatar
        
        self.user_account.text = user_account
    }
    
    private func setupUI(){
        avatar.layer.cornerRadius = 35
    }
    
}
