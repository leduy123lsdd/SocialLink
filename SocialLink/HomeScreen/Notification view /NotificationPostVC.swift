//
//  NotificationPostVC.swift
//  SocialLink
//
//  Created by Lê Duy on 5/21/21.
//


import UIKit
import ImageSlideshow
import ProgressHUD
import Alertift

class NotificationPostVC: UIViewController,ImageSlideshowDelegate {
    
    typealias PostData = [String:Any]
    
    @IBOutlet var displayAvatar: UIImageView!
    @IBOutlet var displayName: UILabel!
    @IBOutlet var uploadTime: UILabel!
    
    @IBOutlet var caption: PaddingLabel!
    @IBOutlet var likes: UILabel!
    @IBOutlet var comments: UILabel!
    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet var likeBtn: UIButton!
    
    @IBOutlet var deleteBtn: UIButton!
    
    var deletedPost:(()->Void)?
    
    var liked = false {
        didSet {
            if liked {
                self.likeBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                self.likeBtn.tintColor = UIColor.blue
            } else {
                self.likeBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                self.likeBtn.tintColor = UIColor.black
            }
        }
    }
    var rootVC:UIViewController?
    var likeClicked:(()->Void)?
    var postId:String?
    
    var localSource = [InputSource]()  {
        didSet {
            slideshow.setImageInputs(self.localSource)
        }
    }
    var reloadRow:(()->Void)?
    
    // MARK: Data of this post
    var postData:PostData?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSlideShow()
        
    }


    // MARK: Parse data for this
    func parseData(data:[String:Any]) {
        self.postData = data
        
        self.postId = data["post_id"] as? String
        self.displayName.text = data["user_account"] as? String
        self.caption.text = data["caption"] as? String
        self.likes.text = "❤️ \((data["liked_by_users"] as? [Any])?.count ?? 0) Likes"
        
        // Get url from firebase reference and add it to slide image
        guard let image_URLs = data["images_url"]  else {
            fatalError()
        }
        for userLike in data["liked_by_users"] as! [String] {
            if userStatus.user_account == userLike {
                self.liked = true
                break
            } else {
                self.liked = false
            }
        }
        
        var imageData = [InputSource]()
        for im_url in (image_URLs as! [URL]) {
            imageData.append(SDWebImageSource(url: im_url))
        }
        
        self.localSource = imageData
        
        // Get url of image from user
        let user_account = (data["user_account"] as? String) ?? ""
        let post_id = (data["post_id"] as? String) ?? ""
        self.postId = post_id
        
        if user_account == userStatus.user_account {
            deleteBtn.isHidden = false
        } else {
            deleteBtn.isHidden = true
        }
        
        ServerFirebase.getAvatarImageURL(user_account: user_account) { urlResponse in
            if let url = urlResponse {
                self.displayAvatar.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    
    
    // MARK: Setup view
    private func setupSlideShow(){
        // Position of page indicator
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customUnder(padding: 5))
        
        
        // Scale for images
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // Indicator color ..
        let pageIndicator = UIPageControl()
        pageIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        pageIndicator.currentPageIndicatorTintColor = UIColor.systemTeal
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        pageIndicator.backgroundColor = UIColor.clear
        
        slideshow.pageIndicator = pageIndicator
        
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: .green)
        slideshow.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDisplayName))
        displayName.isUserInteractionEnabled = false
        displayName.addGestureRecognizer(tap)
        
        // Tap to image from slide show
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapToImage))
          slideshow.addGestureRecognizer(gestureRecognizer)
        
        deleteBtn.isHidden = true 
    }
    
    @objc func didTapToImage() {
        slideshow.presentFullScreenController(from: self.rootVC!)
    }
    
    // MARK: Actions button
    @IBAction func addComment(_ sender: Any) {
        if let rootVC = rootVC {
            let addComment = MakeCommentVC(nibName: "MakeCommentVC", bundle: nil)
            if let post_id = self.postId {
                addComment.postId = post_id
                addComment.post_belong_user = displayName.text ?? ""
            }
            rootVC.navigationController?.pushViewController(addComment, animated: true)
        }
    }
    
    // MARK: Like Btn action
    @IBAction func likeBtn(_ sender: Any) {
        if let like_function = likeClicked {
            like_function()
            
        }
    }
    
    // MARK: Share btn action
    @IBAction func shareBtn(_ sender: Any) {
    }
    
    // MARK: Action when tap to display name
    @objc
    func tapToDisplayName(sender:UITapGestureRecognizer) {
        let userProfileVC = UserProfileVC(nibName: "UserProfileVC", bundle: nil)
        userProfileVC.user_account = displayName.text ?? ""
        userProfileVC.rootView = rootVC
        
        rootVC?.navigationController?.pushViewController(userProfileVC, animated: true)

    }
    
    // MARK: - delete post
    
    
    
    @IBAction func deletePost(_ sender: Any) {
        
        Alertift.alert(title: "Confirm", message: "Delete this post ?")
            .action(.destructive("Oke")) {
                
                ProgressHUD.show()
                
                guard let post_id = self.postId else {
                    ProgressHUD.dismiss()
                    return
                    
                }
                
                
                ServerFirebase.deletePost(post_id: post_id, user_account: userStatus.user_account) {
                    self.rootVC?.navigationController?.popViewController(animated: true)
                    ProgressHUD.dismiss()
                }
                
            }
            .action(.cancel("Cancel"))
            .show()
        
        
        
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }

}
