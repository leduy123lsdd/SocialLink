//
//  StoryCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/22/21.
//

import UIKit
import Pastel

class StoryCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 35
        containerView.backgroundColor = UIColor.init(red: 181, green: 101, blue: 167)
        
        imageView.layer.cornerRadius = 32
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func fillData(image:UIImage?,name:String){
        self.name.text = name
    }
    

}
