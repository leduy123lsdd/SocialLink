//
//  LoginVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/8/21.
//

import UIKit
import ProgressHUD
import Alertift

class LoginVC: UIViewController {
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var accountTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var dismiss_keyboard_1: UIView!
    @IBOutlet weak var dismiss_keyboard_2: UIView!
    
    @IBOutlet var distanceStackToBottom: NSLayoutConstraint!
    @IBOutlet var distanceLoginBtnToBottomScreen: NSLayoutConstraint!
    
    var defaultDistanceStackToBottom:CGFloat?
    let signUpVC = CreateAccountVC(nibName: "CreateAccountVC", bundle: nil)
    let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpUI(){
        defaultDistanceStackToBottom = distanceStackToBottom.constant
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loginBtn.layer.cornerRadius = 6
        
        [accountTf, passwordTf].forEach({ tf in
            tf!.layer.borderWidth = 0.7
            tf!.layer.cornerRadius = 6
            tf!.layer.borderColor = UIColor.white.cgColor
        })
    
        accountTf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTf.attributedPlaceholder = NSAttributedString(string: "Passworld", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        [dismiss_keyboard_1,dismiss_keyboard_2].forEach { (view) in
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard)))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        //Do something here
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            distanceStackToBottom.constant = (50 + keyboardHeight - distanceLoginBtnToBottomScreen.constant)
            
        }
    }

    @objc func keyboardWillDisappear() {
        //Do
        distanceStackToBottom.constant = defaultDistanceStackToBottom!
    }
    
    // MARK: Button actions
    @IBAction func signUpBtn(_ sender: Any) {
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        let account = accountTf.text ?? ""
        let password = passwordTf.text ?? ""
        self.view.endEditing(true)
        ProgressHUD.show()
        
        ServerFirebase.userLogin(account,password) {
            print("login successed")
            ProgressHUD.showSucceed()
            userStatus.setState(userName: account)
            self.navigationController?.pushViewController(self.homeVC, animated: false)
        } loginFailed: {
            ProgressHUD.showFailed()
            
            Alertift.alert(title: "Try again please :)", message: "In case you had forgoten your password. Click forgot password")
                .action(.default("OK"))
                .show(on: self)
            print("login failed")
        }

    }
    
}

