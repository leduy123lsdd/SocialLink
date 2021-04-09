//
//  CommentCell.swift
//  SocialLink
//
//  Created by Lê Duy on 4/1/21.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var uploadTimeLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var replyButton: UIButton!
    
    var doubleTapHandler:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
    
    private func setupUI(){
        commentLabel.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 20
        commentLabel.layer.cornerRadius = 15
        addSingleAndDoubleTapGesture()
        
        
        let fullText = "\(userStatus.user_account)\nHello guys, this is a comment "
        
        let boldString = (fullText as NSString).range(of: userStatus.user_account)
        let attributeBold = NSMutableAttributedString(
            string: fullText,
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        attributeBold.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)], range: boldString)
        
        commentLabel.attributedText = attributeBold
    }
    
    private func addSingleAndDoubleTapGesture() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)

        singleTapGesture.require(toFail: doubleTapGesture)
    }

    @objc private func handleSingleTap(_ tapGesture: UITapGestureRecognizer) {
        print("1 tap")
    }

    @objc private func handleDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        if let doubleTap = doubleTapHandler {
            doubleTap()
        }
        print("2 tap")
    }
    
}
