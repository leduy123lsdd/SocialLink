//
//  SearchUserVC.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit

class SearchUserVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let data = ["leDuy","hoangYen","chicken","watermelon","apple","computer"]
    var filteredData:[String]!

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
        
    }

}
extension SearchUserVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! SearchResultCell
        cell.setLabelName(name: filteredData[indexPath.row])
        return cell
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
        filteredData = []
        if searchText == "" {
            filteredData = []
        } else {
            for itemName in data {
                if itemName.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(itemName)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
