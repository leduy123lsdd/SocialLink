//
//  LoginVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/8/21.
//

import UIKit
import ProgressHUD
import Alertift
import Pastel

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
    
    
    let emoji = ["❤️","👍","🔥","👏","🥺","😢","😍","😂"]
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let color2 = UIColor(rgb: 0x121212)
        
//        backgroundView.backgroundColor = color2
        setupGradientColor()
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
        
        loginBtn.layer.cornerRadius = 25
        
        [accountTf, passwordTf].forEach({ tf in
            tf!.layer.masksToBounds = true
            tf!.layer.borderWidth = 0.7
            tf!.layer.cornerRadius = 8
            tf!.layer.borderColor = UIColor.clear.cgColor
            tf!.setLeftPaddingPoints(10)
            tf!.setRightPaddingPoints(10)
        })
    
        accountTf.attributedPlaceholder = NSAttributedString(string: "User account", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTf.attributedPlaceholder = NSAttributedString(string: "Passworld", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        [dismiss_keyboard_1,dismiss_keyboard_2].forEach { (view) in
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard)))
        }
        
        
        
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
        
        // Login to app
        ServerFirebase.userLogin(account,password) { userInfo in
            print("login successed")
            ProgressHUD.showSucceed()
            
            // Save userName and fiend from server
            userStatus = UserStatus(info_data: userInfo)
            
            let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
            self.navigationController?.pushViewController(homeVC, animated: false)
        } loginFailed: {
            ProgressHUD.showFailed()
            
            Alertift.alert(title: "Try again please :)", message: "In case you had forgoten your password. Click forgot password")
                .action(.default("OK"))
                .show(on: self)
            print("login failed")
        }

    }
    
    // MARK: Setup gradient color
    private func setupGradientColor(){
        let pastelView = PastelView(frame: self.view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 3.0
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0)])
        
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
}

