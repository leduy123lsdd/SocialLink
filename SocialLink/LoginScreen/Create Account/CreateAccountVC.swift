//
//  CreateAccountVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/17/21.
//

import UIKit

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
        nextBtn.isEnabled = false
        let newUser:[String:Any] = [
            "display_name":displayTf.text!,
            "pass_word":passwordTf.text!,
            "user_account":userNameTf.text!
        ]
        
        // Connect to server and sign new user account.
        ServerFirebase.signUpNewUser(newUser: newUser) {
            let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
            self.navigationController?.pushViewController(homeVC, animated: false)
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
