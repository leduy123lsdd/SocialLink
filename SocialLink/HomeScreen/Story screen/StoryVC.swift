//
//  StoryVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit

class StoryVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SubStoryCell", bundle: nil), forCellReuseIdentifier: "SubStoryCell")
        tableView.register(UINib(nibName: "MainContentCell", bundle: nil), forCellReuseIdentifier: "MainContentCell")
    }
    
    
    
}

extension StoryVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            tableView.rowHeight = 110
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubStoryCell") as! SubStoryCell
            return cell
        } else {
            tableView.rowHeight = 400
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainContentCell") as! MainContentCell
            return cell
        }
        
        
        
        
        
    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        return
//    }
    
}
