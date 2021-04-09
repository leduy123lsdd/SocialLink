//
//  PostImageCell.swift
//  SocialLink
//
//  Created by Lê Duy on 4/8/21.
//

import UIKit

class PostImageCell: UICollectionViewCell {
    

    @IBOutlet var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setImage(imageData:UIImage) {
        self.image.image = imageData
    }
}
