//
//  CreateAccountVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/17/21.
//

import UIKit
import ProgressHUD
import Alertift

class CreateAccountVC: UIViewController {
    
    @IBOutlet var endEditView: UIView!
    @IBOutlet var displayTf: UITextField!
    @IBOutlet var userNameTf: UITextField!
    @IBOutlet var passwordTf: UITextField!
    @IBOutlet var nextBtn: UIButton!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        displayTf.becomeFirstResponder()
        endEditView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard)))
        nextBtn.layer.cornerRadius = 6
    }
    
    // MARK: btn actions
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        
        let newUser:[String:Any] = [
            "display_name":displayTf.text!,
            "pass_word":passwordTf.text!,
            "user_account":userNameTf.text!,
            "followers":[String](),
            "following":[String](),
            "posted_id":[String](),
            "amount_post":0,
            "avatarUrl":"",
            "bio":""
        ]
        
        ProgressHUD.show()
        // Check that account is exist or not.
        searchUserService.getAllUsers { usersInfo in
            var exsisted = false
            for user in  usersInfo {
                let user_account = user["user_account"] as! String
                let newUseracc = self.userNameTf.text!
                
                if newUseracc == user_account {
                    exsisted = true
                    break
                }
            }
            
            if !exsisted {
                // Connect to server and sign new user account.
                ServerFirebase.signUpNewUser(newUser: newUser) {
                    let account = self.userNameTf.text ?? ""
                    let password = self.passwordTf.text ?? ""
                    
                    ServerFirebase.userLogin(account, password) { userInfo in
                        
                        userStatus = UserStatus(info_data: userInfo)
                        
                        let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
                        
                        homeVC.didApearVC = {
                            let editProfileVC = EditProfileVC(nibName: "EditProfileVC", bundle: nil)

                            editProfileVC.rootView = homeVC

                            editProfileVC.rootView?.navigationController?.pushViewController(editProfileVC, animated: true)
                            
                        }
                        
                        self.navigationController?.pushViewController(homeVC, animated: false)
                        
                        ProgressHUD.dismiss()
                    } loginFailed: {
                        ProgressHUD.dismiss()
                    }
                }
            } else {
                ProgressHUD.dismiss()
                Alertift.alert(title: "Tài khoản đã tồn tại", message: "Vui lòng đặt tên khác.")
                    .action(.default("OK"))
                    .show(on: self)
            }
            
            
            
        }
        
        
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
