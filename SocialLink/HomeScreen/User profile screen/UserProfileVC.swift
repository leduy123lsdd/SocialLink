//
//  UserProfileVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit
//import FirebaseUI
import Firebase

class UserProfileVC: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var displayName: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var storyCollectionView: UICollectionView!
    
    @IBOutlet var followBtn: UIButton!
    @IBOutlet var messageBtn: UIButton!
    
    
    var images = [UIImage]()
    let storyData = ["doc","cat","bird","mouse","banana","mango"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        
        
    }
    
    private func setupUI(){
        self.nameLabel.text = userStatus.user_account
        self.displayName.text = userStatus.display_name
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PostImageCell", bundle: nil), forCellWithReuseIdentifier: "PostImageCell")
        
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        storyCollectionView.register(UINib(nibName: "StoryCell", bundle: nil), forCellWithReuseIdentifier: "StoryCell")
        
        for index in 1...9 {
            images.append(UIImage(named: "im\(index)")!)
        }
        
        
        let cellWidth = (self.view.frame.width-6) / 3
        let collumn = Int(images.count/3)
        
        if images.count%3 != 0 {
            let collumn = Int(images.count/3)
            
            collectionViewHeight.constant = CGFloat(collumn + 1)*cellWidth
        } else {
            collectionViewHeight.constant = CGFloat(collumn)*cellWidth
        }
        
        
        [followBtn,messageBtn].forEach { btn in
            btn?.layer.borderWidth = 0.6
            btn?.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        
        
        
    }
    
    
    // MARK: - Buttons action.


    @IBAction func postAction(_ sender: Any) {
        print("post clicked")
    }
    @IBAction func followerAction(_ sender: Any) {
        print("follower clicked")
    }
    @IBAction func followingAction(_ sender: Any) {
        print("following clicked")
    }
    @IBAction func editProfile(_ sender: Any) {
        let editProfileVC = EditProfileVC(nibName: "EditProfileVC", bundle: nil)
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
}

extension UserProfileVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return images.count
        }
        if collectionView == self.storyCollectionView {
            return storyData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCell", for: indexPath) as!
                PostImageCell
            cell.setImage(imageData: images[indexPath.row])
            return cell
        }
        if collectionView == self.storyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCell
            cell.fillData(image: nil, name: storyData[indexPath.row])
            cell.name.text = ""
//            cell.containerView.layer.cornerRadius = 30
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            let cellWidth = (self.view.frame.width-6) / 3
            return CGSize(width: cellWidth, height: cellWidth)
        }
        if collectionView == self.storyCollectionView {
            return CGSize(width: 80.0, height: 100.0)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
