//
//  PostImageCell.swift
//  SocialLink
//
//  Created by Lê Duy on 4/8/21.
//

import UIKit

class PostImageCell: UICollectionViewCell {
    
    @IBOutlet var postImage: UIImageView!
    
    var tapIntoImage:(()->Void)?
    
    @IBOutlet var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        postImage.isUserInteractionEnabled = true
        
        // Tap gesture for image
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        postImage.addGestureRecognizer(tapImageGesture)
    }
    
    func setImage(imageData:UIImage) {
        self.image.image = imageData
        
    }
    
    @objc
    func didTapImageView() {
        if let tapAction = tapIntoImage {
            tapAction()
        }
    }
}
