//
//  SearchUserVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit
import ProgressHUD
import SDWebImage

class SearchUserVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    
//    let data = ["leDuy","hoangYen","chicken","watermelon","apple","computer"]
    var filteredData:[[String:Any]]!
    var usersInfo = [[String:Any]]()
    var rootVC:UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
        
        searchBar.delegate = self
        
        filteredData = []
        searchBar.layer.masksToBounds = true
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        // Get all user info availabe in database
        getAllUserInDatabase()
        
    }

    private func getAllUserInDatabase(){
        ProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        
        searchUserService.getAllUsers { usersInfo in
            
            self.usersInfo = usersInfo
            self.filteredData = usersInfo
            
            self.tableView.reloadData()
            self.view.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
    }
}
extension SearchUserVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = filteredData[indexPath.row]
        let user_account = user["user_account"] as! String
        let display_name = user["display_name"] as! String
        let avatar = user["avatarUrl"] as? String
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! SearchResultCell
        
        cell.labelAccount.text = user_account
        cell.labelName.text = display_name
        
        // Set and get avatar
        if let url = avatar {
            let avatarUrl = URL(string: url)
            cell.avatar.sd_setImage(with: avatarUrl, completed: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredData[indexPath.row]
        let user_account = user["user_account"] as! String
        
        let userProfileVC = UserProfileVC(nibName: "UserProfileVC", bundle: nil)
        userProfileVC.user_account = user_account
        userProfileVC.rootView = rootVC
        
        userProfileVC.modalPresentationStyle = .fullScreen
        rootVC?.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

extension SearchUserVC: UISearchBarDelegate {
    // MARK: Search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            filteredData = usersInfo
        } else {
            filteredData = []
            for user in self.usersInfo {
                let user_account = user["user_account"] as! String
                
                if user_account.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(user)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
