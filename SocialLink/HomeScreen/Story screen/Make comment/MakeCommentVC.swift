//
//  MakeCommentVC.swift
//  SocialLink
//
//  Created by Lê Duy on 4/1/21.
//

import UIKit

class MakeCommentVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableviewToTopConstraint: NSLayoutConstraint!
    var defaultConstraint:CGFloat?
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var commentSection: UITextField!
    @IBOutlet var commentToBottomArea: NSLayoutConstraint!
    
    let emoji = ["❤️","👍","🔥","👏","🥺","😢","😍","😂"]
    
    
    @IBAction func btn1(_ sender: Any) {
        commentSection.text! += emoji[0]
    }
    @IBAction func btn2(_ sender: Any) {
        commentSection.text! += emoji[1]
    }
    @IBAction func btn3(_ sender: Any) {
        commentSection.text! += emoji[2]
    }
    @IBAction func btn4(_ sender: Any) {
        commentSection.text! += emoji[3]
    }
    @IBAction func btn5(_ sender: Any) {
        commentSection.text! += emoji[4]
    }
    @IBAction func btn6(_ sender: Any) {
        commentSection.text! += emoji[5]
    }
    @IBAction func btn7(_ sender: Any) {
        commentSection.text! += emoji[6]
    }
    @IBAction func btn8(_ sender: Any) {
        commentSection.text! += emoji[7]
    }
    
    @IBAction func sendComment(_ sender: Any) {
        commentSection.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        print("viewWillAppear")
        self.navigationController?.isNavigationBarHidden = false
    }
    

    
    

    private func setupUI(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        defaultConstraint = tableviewToTopConstraint.constant
        
        userImage.layer.cornerRadius = 20
        commentSection.layer.masksToBounds = true
        commentSection.layer.cornerRadius = 20
        commentSection.layer.borderColor = UIColor.lightGray.cgColor
        commentSection.layer.borderWidth = 0.6
        commentSection.setLeftPaddingPoints(10)
        commentSection.setRightPaddingPoints(40)
        
        self.navigationItem.title = "Comments"
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.backBarButtonItem?.title = ""
        
        
        
        
    }
    
    // MARK: - Hide and show keyboard
    @objc private func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            commentToBottomArea.constant = -keyboardSize.height - 10
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            commentToBottomArea.constant = -10
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
            
        }
    }

}

extension MakeCommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        commentSection.endEditing(true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
}
