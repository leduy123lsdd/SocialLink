//
//  SubStoryCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/20/21.
//

import UIKit
import YPImagePicker
import iOSPhotoEditor
import SDWebImage

class SubStoryCell: UITableViewCell {
    @IBOutlet var collectionView: UICollectionView!
    
    var rootVC:UIViewController?
    
    typealias DictType = [String:Any]
    var storyData = [[DictType]]()
    
    var config = YPImagePickerConfiguration()
    var picker:YPImagePicker!
    let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "StoryCell", bundle: nil), forCellWithReuseIdentifier: "StoryCell")
        collectionView.register(UINib(nibName: "AddStoryCell", bundle: nil), forCellWithReuseIdentifier: "AddStoryCell")
        
        config.library.maxNumberOfItems = 1
        config.usesFrontCamera = true
        config.screens = [.photo,.library]
        picker = YPImagePicker(configuration: config)
        
        photoEditor.modalPresentationStyle = .fullScreen
        
        photoEditor.photoEditorDelegate = self
//        photoEditor.image = UIImage(named: "crush")!
//        photoEditor.stickers.append(UIImage(named: "9" )!)
//        photoEditor.stickers.append(UIImage(named: "empty" )!)
        photoEditor.hiddenControls = [.save,.share]
        photoEditor.colors = [.brown,.purple,.orange,.magenta,.yellow,.cyan,.blue,.green,.red,.white,.black]
        
        
        
        fetchFollowerUsers()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        selectionStyle = .none
    }
    
    var userStoryAvatar = [DictType]()
    
    // Get all stories of follower
    private func fetchFollowerUsers() {
        
        userStoryAvatar.removeAll()
        storyData.removeAll()
        
        ServerFirebase.getAvatarImageURL(user_account: userStatus.user_account) { url in
            let newData:[String : Any] = ["user_account":userStatus.user_account,
                                          "avatarURL":url as Any]
            
            self.userStoryAvatar.append(newData)
            self.collectionView.reloadData()
        }
        
        ServerFirebase.getUserProfile(user_account: userStatus.user_account) { (dataRes) in
            guard let data = dataRes,
                  let followersDict = data["followers"],
                  var followers = followersDict as? [String] else  {return}
            followers.append(userStatus.user_account)
            for user in followers {
                searchUserService.getStory(for: user) { (dataArr) in
                    
                    let dataNew = dataArr as! [DictType]
                    
                    if dataNew.count > 0 {
                        self.storyData.append(dataNew)
                        self.collectionView.reloadData()
                        
                        ServerFirebase.getAvatarImageURL(user_account: user) { url in
                            let newData:[String : Any] = ["user_account":user,"avatarURL":url as Any]
                            self.userStoryAvatar.append(newData)
                            self.collectionView.reloadData()
                        }
                    }
                    
                }
            }
            
        }
    }
    
}

// MARK: - Photo editor delegation
extension SubStoryCell: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        searchUserService.uploadStory(image: image, user_account: userStatus.user_account) {
            
            self.fetchFollowerUsers()
        } failed: {
            
        }

    }
    
    func canceledEditing() {
        
    }
}

// MARK: - UICollectionView delegation
extension SubStoryCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStoryCell", for: indexPath) as! AddStoryCell
            for user in userStoryAvatar {
                let user_account = user["user_account"] as! String
                let avatarURL = user["avatarURL"] as! URL
                
                if user_account == userStatus.user_account {
                    cell.imageView.sd_setImage(with: avatarURL, completed: nil)
                    break
                }
            }
            return cell
        }
        
        let data = self.storyData[indexPath.row - 1]
        let firstStory = data.first
        let user_account = firstStory?["user_account"] as? String
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCell

        
        for user in userStoryAvatar {
            let user_acc = user["user_account"] as! String
            let avatarURL = user["avatarURL"] as! URL
            
            if user_acc == user_account {
                cell.name.text = user_acc
                cell.imageView.sd_setImage(with: avatarURL, completed: nil)
                break
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80.0, height: 100.0)
    }
    
    
    
    // MARK: Select a story
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                if cancelled {
                    picker?.dismiss(animated: true, completion: nil)
                    return
                }
                
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self.photoEditor.image = photo.image
                    case .video(let video):
                        print(video)
                    }
                }
                
                picker?.dismiss(animated: true, completion: {
                    self.rootVC?.present(self.photoEditor, animated: true, completion: nil)
                })
                
            }

            rootVC?.present(picker, animated: true, completion: nil)
        }
        
//        print(self.storyData[indexPath.row-1])
        
    }
}
