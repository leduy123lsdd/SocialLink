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
    @IBOutlet var viewAllReplies: UIButton!
    
    
    @IBOutlet var amountLikes: UILabel!
    
    
    @IBOutlet var heartBtn: UIButton!
    
    var doubleTapHandler:(()->Void)?
    var replyAction:(()->Void)?
    var viewAllRepliesAction:(()->Void)?
    
    
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
        avatarImage.layer.cornerRadius = 15
        commentLabel.layer.cornerRadius = 15
        addSingleAndDoubleTapGesture()
        
    }
    
    func setComment(_ comment:String, user_account:String){
        let fullText = "\(user_account)\n\(comment)"
        
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
    
    // MARK: - Reply button action
    @IBAction func replyBtnAction(_ sender: Any) {
        if let reply = replyAction {
            reply()
        }
        
    }
    
    // MARK: - View replies button action
    @IBAction func viewAllReplies(_ sender: Any) {
        if let viewRepliesClicked = viewAllRepliesAction {
            viewRepliesClicked()
        }
    }
    
    var likeCommentAction:(()->Void)?
    @IBAction func likeActionBtn(_ sender: Any) {
        if let like = likeCommentAction {
            like()
        }
    }
}
