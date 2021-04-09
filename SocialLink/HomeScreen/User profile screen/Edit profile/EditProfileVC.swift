//
//  EditProfileVC.swift
//  SocialLink
//
//  Created by Lê Duy on 4/9/21.
//

import UIKit

class EditProfileVC: UIViewController {
    
    
    @IBOutlet var displayName: UITextField!
    @IBOutlet var bio: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        print("Cancel pressed")
        navigationController?.popViewController(animated: true)
    }
    @IBAction func doneBtn(_ sender: Any) {
        print("Done pressed")
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI(){
        [displayName,bio].forEach({ tf in
            tf?.layer.masksToBounds = false
            tf?.layer.borderWidth = 0
            tf?.layer.borderColor = UIColor.white.cgColor
        })
    }

}
