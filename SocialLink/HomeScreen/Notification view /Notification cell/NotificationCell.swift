//
//  NotificationCell.swift
//  SocialLink
//
//  Created by Lê Duy on 5/21/21.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    
    
    @IBOutlet var backgroundColorView: UIView!
    
    @IBOutlet var avatar: UIImageView!
    

    @IBOutlet var messageLb: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
