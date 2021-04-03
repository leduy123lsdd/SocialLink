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
    var rootVC:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Fetch posts, from friends
    
    // MARK: - Add reply for each comment
    
    // MARK: - setup UI
    private func setupUI(){
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
            tableView.rowHeight = 100
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubStoryCell") as! SubStoryCell
            return cell
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1200
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainContentCell") as! MainContentCell
        cell.rootVC = self.rootVC
        return cell
        
    }
    
}
