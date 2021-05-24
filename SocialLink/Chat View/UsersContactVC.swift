//
//  UsersContactVC.swift
//  SocialLink
//
//  Created by Lê Duy on 5/24/21.
//

import UIKit

class UsersContactVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet var chatView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserContactCell", bundle: nil), forCellReuseIdentifier: "UserContactCell")
        
        tableView.isHidden = false
        chatView.isHidden = true
    }

    
    
}

extension UsersContactVC: UITableViewDelegate,
                          UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserContactCell") as! UserContactCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
