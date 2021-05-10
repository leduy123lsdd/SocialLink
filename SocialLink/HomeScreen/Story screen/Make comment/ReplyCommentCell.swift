//
//  ReplyCommentCell.swift
//  SocialLink
//
//  Created by Lê Duy on 4/13/21.
//

import UIKit

class ReplyCommentCell: UITableViewCell {
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var uploadTimeLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var replyButton: UIButton!
    
    
    @IBOutlet var heartBtn: UIButton!
    @IBOutlet var amountLikes: UILabel!
    
    var replyBtnAction:(()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    private func setupUI(){
        commentLabel.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 15
        commentLabel.layer.cornerRadius = 15
    }
    
    func setComment(_ comment:String, user_account:String){
        let fullText = "\(user_account)\n\(comment)"
        
        let boldString = (fullText as NSString).range(of: userStatus.user_account)
        let attributeBold = NSMutableAttributedString(
            string: fullText,
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
        attributeBold.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)], range: boldString)
        
        commentLabel.attributedText = attributeBold
    }
    
    
    @IBAction func replyBtnAction(_ sender: Any) {
        if let action = replyBtnAction {
            action()
        }
    }
    var likeReplyAction:(()->Void)?
    @IBAction func likeReplyAction(_ sender: Any) {
        if let action = likeReplyAction {
            action()
        }
    }
}
