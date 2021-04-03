//
//  MainContentCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/20/21.
//

import UIKit

class MainContentCell: UITableViewCell {
    
    var rootVC:UIViewController?
    
//    @IBOutlet var avatarImage: UIImageView!
//    @IBOutlet var userName: UILabel!
//    @IBOutlet var uploadTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
    }
    
    private func setupUI(){
        
//        avatarImage.layer.cornerRadius = 20
//        avatarImage.layer.borderWidth = 2
//        avatarImage.layer.borderColor = UIColor.white.cgColor
        
    }
    
    
    @IBAction func addComment(_ sender: Any) {
        if let rootVC = rootVC {
            let addComment = MakeCommentVC(nibName: "MakeCommentVC", bundle: nil)
            rootVC.navigationController?.pushViewController(addComment, animated: true)
        }
        
    }
    
}
