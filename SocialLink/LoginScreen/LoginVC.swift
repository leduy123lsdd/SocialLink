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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let color2 = UIColor(rgb: 0x121212)
        
        backgroundView.backgroundColor = color2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
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
    
    
    
    @IBAction func loginClicked(_ sender: Any) {
        let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
        navigationController?.pushViewController(homeVC, animated: false)
    }
    
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
