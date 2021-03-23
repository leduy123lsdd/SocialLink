//
//  CreateAccountVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/17/21.
//

import UIKit

class CreateAccountVC: UIViewController {
    
    
    @IBOutlet var underlinePhone: UIView!
    @IBOutlet var underlineEmail: UIView!
    
    @IBOutlet var underlinePhoneHeight: NSLayoutConstraint!
    @IBOutlet var underlineEmailHeight: NSLayoutConstraint!
    
    
    @IBOutlet var phoneBtn: UIButton!
    @IBOutlet var emailBtn: UIButton!
    
    
    @IBOutlet var phoneTf: UITextField!
    @IBOutlet var emailTf: UITextField!
    
    
    @IBOutlet var nextBtn: UIButton!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnClicked(is: true)
        phoneTf.becomeFirstResponder()
        endEditView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard)))
        nextBtn.layer.cornerRadius = 8
    }
    
    // MARK: btn actions
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func phoneBtn(_ sender: Any) {
        btnClicked(is: true)
        phoneTf.becomeFirstResponder()
    }
    
    @IBAction func emailBtn(_ sender: Any) {
        btnClicked(is: false)
        emailTf.becomeFirstResponder()
    }
    
    
    @IBOutlet var endEditView: UIView!
    
    private func btnClicked(is phone:Bool = false) {
        emailBtn.setTitleColor(phone ? .lightGray : .black, for: .normal)
        underlineEmailHeight.constant = phone ? 0.5 : 2
        underlineEmail.backgroundColor = phone ? UIColor.lightGray : UIColor.black
        emailTf.isHidden = phone ? true : false
        emailTf.endEditing(phone ? true : false)
        
        phoneBtn.setTitleColor(phone ? .black : .lightGray, for: .normal)
        underlinePhoneHeight.constant = phone ? 2 : 0.5
        underlinePhone.backgroundColor = phone ? UIColor.black : UIColor.darkGray
        phoneTf.isHidden = phone ? false : true
        phoneTf.endEditing(phone ? true : false)
    }
    
}
