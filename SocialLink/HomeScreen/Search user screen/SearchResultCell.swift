//
//  SearchResultCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/15/21.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var labelAccount: UILabel!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet var avatar: UIImageView!
    
//    @IBOutlet weak var image: UIImageView!
    
//    @IBOutlet var image2: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageContainer.layer.cornerRadius = 25
        avatar.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLabelName(name:String) {
        labelAccount.text = name
        labelName.text = name
    }
    
}
