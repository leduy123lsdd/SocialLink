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
    
    let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
    
    let viewStoryViewController = ViewStoryViewController(nibName: "ViewStoryViewController", bundle: nil)
    
    var yourStoryCellData:[String:Any]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(IGAddStoryCell.self, forCellWithReuseIdentifier: IGAddStoryCell.reuseIdentifier)
        collectionView.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier)
        
       
        
        photoEditor.modalPresentationStyle = .fullScreen
        
        photoEditor.photoEditorDelegate = self
        photoEditor.hiddenControls = [.save,.share]
        photoEditor.colors = [.brown,.purple,.orange,.magenta,.yellow,.cyan,.blue,.green,.red,.white,.black]
        
        
        viewStoryViewController.viewStoryDelegate = self
        
        fetchFollowerUsers()
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        selectionStyle = .none
    }
    
    var userStoryAvatar = [DictType]()
    
    // Get all stories of follower
    public func fetchFollowerUsers() {
        
        
        
        ServerFirebase.getUserProfile(user_account: userStatus.user_account) { (dataRes) in
            self.userStoryAvatar.removeAll()
            self.storyData.removeAll()
            guard let data = dataRes,
                  let followersDict = data["followers"],
                  var followers = followersDict as? [String] else  {return}
            
            followers.append(userStatus.user_account)
            
            
            for user in followers {
                
                searchUserService.getStory(for: user) { (dataArr) in
                    
                    let dataNew = dataArr as! [DictType]
                    
                    if dataNew.count > 0 {
                        ServerFirebase.getAvatarImageURL(user_account: user) { url in
                            
                            let newData:[String : Any] = ["user_account":user,"avatarURL":"\(url!)"]
                            self.userStoryAvatar.append(newData)
                            self.storyData.append(dataNew)
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier, for: indexPath) as? IGAddStoryCell else { fatalError() }
            
            if let currentUser = self.yourStoryCellData {
                let avatarURL = currentUser["avatarURL"] as! String
                cell.userDetails = ("Your story","\(avatarURL)")
            } else {
                ServerFirebase.getAvatarImageURL(user_account: userStatus.user_account) { url in
                    
                    let newData:[String : Any] = ["user_account":userStatus.user_account,"avatarURL":"\(url!)"]
                    self.yourStoryCellData = newData
                    
                    cell.userDetails = ("Your story","\(url!)")
                }
            }

            
            return cell
        } else {
            let data = self.storyData[indexPath.row - 1]
            let firstStory = data.first
            let user_account = firstStory?["user_account"] as? String
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,
                                                                for: indexPath) as? IGStoryListCell else { fatalError() }

            for user in userStoryAvatar {
                let user_acc = user["user_account"] as! String
                let avatarURL = user["avatarURL"] as! String
                
                if user_acc == user_account {
                    cell.userDetails = (user_acc,"\(avatarURL)")
                    return cell
                }
            }
            
            
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == 0 ? CGSize(width: 80, height: 100) : CGSize(width: 80, height: 100)
    }
    
    // MARK: Select a story
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var picker:YPImagePicker!
            config.library.maxNumberOfItems = 1
            config.usesFrontCamera = true
            config.screens = [.photo,.library]
            config.library.isSquareByDefault = false
            config.showsCrop = YPCropType.none
            
            picker = YPImagePicker(configuration: config)

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
        } else {
            
            let data = storyData[indexPath.row - 1]
            
            viewStoryViewController.storyData = self.storyData
            viewStoryViewController.userStoryAvatar = self.userStoryAvatar
            viewStoryViewController.fetchData(datas: data)
            
            rootVC?.present(viewStoryViewController, animated: true, completion: nil)
        }
        
    }
}

extension SubStoryCell:SelectNewStory {
    func newStoryLoction(location: Int) {
    }
}
