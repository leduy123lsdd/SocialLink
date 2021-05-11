//
//  AddStoryCell.swift
//  SocialLink
//
//  Created by Lê Duy on 5/10/21.
//

import UIKit

class AddStoryCell: UICollectionViewCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 35
        
        imageView.layer.cornerRadius = 33
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
    }

}
