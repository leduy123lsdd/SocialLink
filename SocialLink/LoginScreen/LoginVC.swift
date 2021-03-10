//
//  LoginVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/8/21.
//

import UIKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet var backgroundView: UIView!
    

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
        loginBtn.layer.cornerRadius = 8
        
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
