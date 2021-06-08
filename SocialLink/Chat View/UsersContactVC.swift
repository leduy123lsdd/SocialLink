//
//  UsersContactVC.swift
//  SocialLink
//
//  Created by Lê Duy on 5/24/21.
//

/**
 flow of this view:
     1. GEt all conversation if it have your name , fetch it in tableview.
     2. Fill date by typing user name into serach bar .
     3. Click into a cell and chet view popup
 */

import UIKit

class UsersContactVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var rootVC:UIViewController?
    
    var chatRooms = [[String:Any]]()
    var filterChatRooms = [[String:Any]]()
    var chatRoomsForTableView = [[String:Any]]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserContactCell", bundle: nil), forCellReuseIdentifier: "UserContactCell")
        
        searchBar.delegate = self
        
        // Make new contact.
        
        let sender = Sender(senderId: "duy123", displayName: "duy123")
        
        
        // Get chatrooms already.
        messageServer.getChatRoomsFor(user: userStatus.user_account) { chatRooms in
            self.chatRooms = chatRooms
            self.chatRoomsForTableView = chatRooms
            
            
            
            self.tableView.reloadData()
        }
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc
    func refreshData() {
        refreshControl.beginRefreshing()
        messageServer.getChatRoomsFor(user: userStatus.user_account) { chatRooms in
            self.chatRooms = chatRooms
            self.chatRoomsForTableView = chatRooms
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Back button

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UsersContactVC: UITableViewDelegate,
                          UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomsForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataChatRoom = chatRoomsForTableView[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserContactCell") as! UserContactCell
        
        let user1 = dataChatRoom["user1"] as! String
        let user2 = dataChatRoom["user2"] as! String
        
        let read = dataChatRoom["read"] as! String
        
        if read == "false" {
//            cell.backgroundColor = UIColor.systemTeal
            cell.lastText.text = "Có tin nhắn chưa đọc"
        
        } else {
//            cell.backgroundColor = UIColor.white
            cell.lastText.text = ""
        }
        
        // Set avatar
        if user1 != userStatus.user_account {
            ServerFirebase.getAvatarImageURL(user_account: user1) { (url) in
                if let avatarUrl = url {
                    cell.avatar.sd_setImage(with: avatarUrl, completed: nil)
                }
            }
            cell.user_account.text = user1
        } else {
            ServerFirebase.getAvatarImageURL(user_account: user2) { (url) in
                if let avatarUrl = url {
                    cell.avatar.sd_setImage(with: avatarUrl, completed: nil)
                }
            }
            cell.user_account.text = user2
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataChatRoom = chatRoomsForTableView[indexPath.row]
        let user1 = dataChatRoom["user1"] as! String
        let user2 = dataChatRoom["user2"] as! String
        let chatRoom_id = dataChatRoom["chatRoom_id"] as! String
        
        let mss = MessagesVC(nibName: "MessagesVC", bundle: nil)
        
        mss.currentSenderUser = Sender(senderId: userStatus.user_account, displayName: userStatus.user_account)
        mss.chatRoom_id = chatRoom_id
        
        if user1 != userStatus.user_account {
            mss.sender2 = Sender(senderId: user1, displayName: user1)
        } else {
            mss.sender2 = Sender(senderId: user2, displayName: user2)
        }
        
        messageServer.readMss(chatRoom_id: chatRoom_id) {
            messageServer.getChatRoomsFor(user: userStatus.user_account) { chatRooms in
                self.chatRooms = chatRooms
                self.chatRoomsForTableView = chatRooms
                self.tableView.reloadData()
            }
        }
        
        
        self.present(mss, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension UsersContactVC: UISearchBarDelegate {
    // MARK: Search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
//            filteredData = usersInfo
        } else {
//            filteredData = []
//            for user in self.usersInfo {
//                let user_account = user["user_account"] as! String
//
//                if user_account.lowercased().contains(searchText.lowercased()) {
//                    filteredData.append(user)
//                }
//            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
