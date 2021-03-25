//
//  LoginVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/8/21.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var accountTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var dismiss_keyboard_1: UIView!
    @IBOutlet weak var dismiss_keyboard_2: UIView!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let color2 = UIColor(rgb: 0x121212)
        
        backgroundView.backgroundColor = color2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setUpUI()
    }
    
    func setUpUI(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loginBtn.layer.cornerRadius = 6
        
        [accountTf, passwordTf].forEach({ tf in
            tf!.layer.borderWidth = 0.5
            tf!.layer.cornerRadius = 6
            tf!.layer.borderColor = UIColor.lightGray.cgColor
        })
    
        accountTf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTf.attributedPlaceholder = NSAttributedString(string: "Passworld", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        [dismiss_keyboard_1,dismiss_keyboard_2].forEach { (view) in
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard)))
        }
        
    }
    
    // MARK: Button actions
    @IBAction func signUpBtn(_ sender: Any) {
        let signUpVC = CreateAccountVC(nibName: "CreateAccountVC", bundle: nil)
        
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
    
    @IBAction func loginClicked(_ sender: Any) {
        let account = accountTf.text ?? ""
        let password = passwordTf.text ?? ""
        
        ServerFirebase.userLogin(account,password) {
            print("login successed")
            self.navigationController?.pushViewController(self.homeVC, animated: false)
        } loginFailed: {
            print("login failed")
        }

    }
    
}

