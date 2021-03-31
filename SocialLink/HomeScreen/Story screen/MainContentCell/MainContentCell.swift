//
//  MainContentCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/20/21.
//

import UIKit

class MainContentCell: UITableViewCell {
    
    
    @IBOutlet var avatarContainer: UIView!
    @IBOutlet var avatarImage: UIImageView!
    
    
    @IBOutlet var commentUserAvt: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
    }
    
    private func setupUI(){
        avatarContainer.layer.cornerRadius = 20
        avatarContainer.backgroundColor = .green
        
        avatarImage.layer.cornerRadius = 18
        avatarImage.layer.borderWidth = 2
        avatarImage.layer.borderColor = UIColor.white.cgColor
        
        commentUserAvt.layer.cornerRadius = 15
    }
    
}
