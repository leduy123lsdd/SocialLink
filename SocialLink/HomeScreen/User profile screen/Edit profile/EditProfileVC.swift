//
//  EditProfileVC.swift
//  SocialLink
//
//  Created by Lê Duy on 4/9/21.
//

import UIKit
import YPImagePicker
import ProgressHUD
import SDWebImage
import Alertift

class EditProfileVC: UIViewController {
    
    var rootView:UIViewController?
    /**
     1: Thêm màn hình chọn image
     2: Xử lí update avatar lên server
     3: Xử lí nút dont:
        - Ấn done để upload các dữ liệu như ảnh
        - Cancel để hủy cập nhật
     */
    // MARK: Layoyt 
    @IBOutlet var displayName: UITextField!
    @IBOutlet var bio: UITextField!
    @IBOutlet var avatarImage: UIImageView!
    
    // MARK: Variables
    var config = YPImagePickerConfiguration()
    var picker:YPImagePicker!
    var pickedImages = [UIImage]()
    var reloadUserInfo:(()->Void)?
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration for imagePicker
        config.screens = [.photo,.library]
        config.library.maxNumberOfItems = 1
        
        // Set up ui for view
        setupUI()
        getUserData()
    }
    
    // MARK: Get data
    func getUserData(){
        ServerFirebase.getUserProfile(user_account: userStatus.user_account) { userInfoRes in
            if let userInfo = userInfoRes {
                let bio = userInfo["bio"] as! String
                let display_name = userInfo["display_name"] as! String
                
                let avatarUrlString  = userInfo["avatarUrl"] as! String
                let avatarUrl = URL(string: avatarUrlString)
                
                // Set current name for 2 textfield "bio" and "display name".
                if display_name == "" {
                    self.displayName.placeholder = "Your display name"
                } else {
                    self.displayName.placeholder = display_name
                }

                if bio == "" {
                    self.bio.placeholder = "Your bio (optional)"
                } else {
                    self.bio.placeholder = bio
                }
                
                // Change current avatar
                self.avatarImage.sd_setImage(with: avatarUrl, completed: nil)
            }
        }
    }
    
    // MARK: Cancel button action
    @IBAction func cancelBtn(_ sender: Any) {
        print("Cancel pressed")
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Update button action
    @IBAction func updateBtn(_ sender: Any) {
        
        ProgressHUD.show()
        
        // Prepare data of new profile
        let display_name_edit = displayName.text
        let bio_edit = bio.text
        
        
        
        let imageData = pickedImages.first?.jpegData(compressionQuality: 0.2)
        
        // Send new profile to server 
        ServerFirebase.updateProfile(user_account: userStatus.user_account ,
                                     display_name: display_name_edit,
                                     bio: bio_edit,
                                     avatar: imageData) {
            
            self.avatarImage.image = self.pickedImages.first
            ProgressHUD.showSuccess()
            self.navigationController?.popViewController(animated: true)
            if let reload = self.reloadUserInfo {
                reload()
            }
        } failed: {
            ProgressHUD.showFailed()
        }
        
        
    }
    
    // MARK: Change profile button action
    @IBAction func changeProfilePhotoAction(_ sender: Any) {
        
        picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            
            for item in items {
                switch item {
                case .photo(let photo):
                    self.pickedImages.append(photo.image)
                    self.avatarImage.image = photo.image
                case .video(v: let v):
                    print(v)
                }
            }
            
            picker?.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    // MARK: Sign out button action 
    @IBAction func signOutBtnAction(_ sender: Any) {
        Alertift.alert(title: "Confirm", message: "Really want to log out ?")
            .action(.destructive("Sign Out")) {
                userStatus = UserStatus()
                self.rootView?.navigationController?.popToRootViewController(animated: true)
                
            }
            .action(.cancel("Cancel"))
            .show()
    }
    
    //MARK: Setup ui functions
    private func setupUI(){
        [displayName,bio].forEach({ tf in
            tf?.layer.masksToBounds = false
            tf?.layer.borderWidth = 0
            tf?.layer.borderColor = UIColor.white.cgColor
        })
    }

}
