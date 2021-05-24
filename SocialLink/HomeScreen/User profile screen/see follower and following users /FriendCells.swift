//
//  FriendCells.swift
//  SocialLink
//
//  Created by Lê Duy on 5/22/21.
//

import UIKit

class FriendCells: UITableViewCell {
    
    
    @IBOutlet var avatar: UIImageView!
    
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        selectionStyle = .none
    }
    
    public func parseData(avatar:UIImage, name:String){
        self.avatar.image = avatar
        self.name.text = name
        
    }
    
}
