//
//  ViewStoryViewController.swift
//  SocialLink
//
//  Created by Lê Duy on 5/17/21.
//

import UIKit
import ImageSlideshow
import SDWebImage

import IQKeyboardManagerSwift

protocol SelectNewStory {
    func newStoryLoction(location:Int)
}
class ViewStoryViewController: UIViewController {
    
    @IBOutlet var slideShow: ImageSlideshow!
    @IBOutlet var sendMessageTf: UITextField!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var userAccountLb: UILabel!
    
    
    @IBOutlet weak var sendMss: UIButton!
    
    var dongthoigianView = false 
    
    var storyImages:[InputSource]!
    
    typealias DictType = [String:Any]
    var storyData = [[DictType]]()
    
    var userStoryAvatar = [DictType]()
    
    var user_account:String!
    
    var viewStoryDelegate:SelectNewStory?
    
    var sendMssToUser = ""
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSlideShow()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier)
        
        sendMessageTf.layer.borderWidth = 0.6
        sendMessageTf.layer.borderColor = UIColor.white.cgColor
        sendMessageTf.attributedPlaceholder = NSAttributedString(string: "Send a message",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        
        updateView()
    }
    
    private func updateView(){
        userAccountLb.text = user_account
        
        self.slideShow.setImageInputs(self.storyImages)
        
        if dongthoigianView {
            ServerFirebase.getAvatarImageURL(user_account: self.user_account) { (url) in
                guard let url = url else { return}
                    
                self.avatarImage.sd_setImage(with: url, completed: nil)
                    
                
            }
        } else {
            for user in userStoryAvatar {
                
                let userAccount = user["user_account"] as! String
                
                if self.user_account == userAccount {
                    let avatarURL = user["avatarURL"] as! String
                    guard let URL = URL(string: avatarURL) else {return}
                    avatarImage.sd_setImage(with: URL, completed: nil)
                    
                    break
                }
                
                
            }
        }
        
        
    }
    
    func parseData(images_URL:[URL]){
        storyImages = [InputSource]()
        for url in images_URL {
            storyImages.append(SDWebImageSource(url: url))
            
        }
    }
    
    func fetchData(datas:[[String:Any]], shouldUpdateView:Bool = false){
        storyImages = [InputSource]()
        
        var breakLoop = false
        
        for data in datas {
            if !breakLoop {
                let user_account = data["user_account"] as! String
                self.user_account = user_account
                breakLoop = true
            }
            
            let url = data["url"] as! String
            guard let url_data = URL(string: url) else {return}
            storyImages.append(SDWebImageSource(url: url_data))
        }
        
        if shouldUpdateView {
            updateView()
        }
    }
    
    private func setupSlideShow(){
        // Position of page indicator
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        
        // Scale for images
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // Indicator color ..
        let pageIndicator = UIPageControl()
        pageIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        pageIndicator.currentPageIndicatorTintColor = UIColor.systemTeal
        pageIndicator.pageIndicatorTintColor = UIColor.black
        pageIndicator.backgroundColor = UIColor.clear
        
        
        slideShow.pageIndicator = pageIndicator
        
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideShow.activityIndicator = DefaultActivityIndicator(style: .medium, color: .gray)
        slideShow.delegate = self
    }
    
    // MARK: - Send reply to story.
    
    @IBAction func sendMss(_ sender: Any) {
    
        let message  = sendMessageTf.text
        let user1 = userStatus.user_account
        let user2 = sendMssToUser
        
        if message != "" {
            messageServer.findChatRoomForUsers(user1: user1, user2: user2) { (chatRoom_id_res) in
                if let chatRoom_id = chatRoom_id_res {
                    messageServer.addNewMessage(chatRoom_id: chatRoom_id, sender: Sender(senderId: user1, displayName: user1), message: message!) { _ in
                        self.sendMessageTf.text = ""
                        self.sendMessageTf.resignFirstResponder()
                    }
                } else {
                    messageServer.makeNewChatRoom(user1: user1, user2: user2) { (chatRoom_id) in
                        messageServer.addNewMessage(chatRoom_id: chatRoom_id, sender: Sender(senderId: user1, displayName: user1), message: message!) { _ in
                            self.sendMessageTf.text = ""
                            self.sendMessageTf.resignFirstResponder()
                        }
                    }
                }
            }
        }
    }
}

extension ViewStoryViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
    }
}

extension ViewStoryViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.storyData[indexPath.row]
        let firstStory = data.first
        let user_account = firstStory?["user_account"] as! String
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,
                                                            for: indexPath) as? IGStoryListCell else { fatalError() }
        
        if indexPath.row == 0 {
            if user_account == userStatus.user_account {
                sendMss.backgroundColor = UIColor.gray
                sendMss.isEnabled = false
                sendMssToUser = ""
            } else {
                sendMss.backgroundColor = UIColor.link
                sendMss.isEnabled = true
                sendMssToUser = user_account
            }
        }
        
        if dongthoigianView {
            let avatar_URL = firstStory?["url"] as! String
            cell.userDetails = ("","\(avatar_URL)")
        } else {
        
            for user in userStoryAvatar {
                let user_acc = user["user_account"] as! String
                let avatarURL = user["avatarURL"] as! String
                
                if user_acc == user_account {
                    cell.userDetails = (user_acc,"\(avatarURL)")
                    break
                }
            }
        }
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = storyData[indexPath.row]
        let firstStory = data.first
        let user_account = firstStory?["user_account"] as! String
        if user_account == userStatus.user_account {
            sendMss.backgroundColor = UIColor.gray
            sendMss.isEnabled = false
            sendMssToUser = ""
        } else {
            sendMss.backgroundColor = UIColor.link
            sendMss.isEnabled = true
            sendMssToUser = user_account
        }
        fetchData(datas: data, shouldUpdateView: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 80, height: 100) : CGSize(width: 80, height: 100)
    }
    
}
    
extension ViewStoryViewController: UITextFieldDelegate {
    
}
