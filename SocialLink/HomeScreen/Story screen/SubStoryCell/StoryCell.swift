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
        let heigheContainer = containerView.frame.height
        let heightImage = imageView.frame.height
        
        containerView.layer.cornerRadius = heigheContainer/2
        containerView.backgroundColor = UIColor.init(red: 181, green: 101, blue: 167)
        containerView.backgroundColor = UIColor.white
        
        imageView.layer.cornerRadius = heightImage/2
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.orange.cgColor
    }
    
    func fillData(image:UIImage?,name:String){
        self.name.text = name
    }
    

}
