//
//  StoryCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/22/21.
//

import UIKit

class StoryCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 35
        containerView.backgroundColor = .green
        
        imageView.layer.cornerRadius = 33
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func fillData(image:UIImage?,name:String){
//        self.imageView.image = image
        self.name.text = name
    }

}
