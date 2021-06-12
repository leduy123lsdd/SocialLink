//
//  MessagesVC.swift
//  SocialLink
//
//  Created by Lê Duy on 5/24/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessagesVC: MessagesViewController,
                  MessagesDataSource,
                  MessagesLayoutDelegate,
                  MessagesDisplayDelegate {
    
    var messagesData = [MessageType]()
    var chatRoom_id = ""
    var currentSenderUser:Sender!
    var sender2:Sender! {
        didSet {
            ServerFirebase.getAvatarImageURL(user_account: sender2.senderId) { (URL) in
                if let url = URL {
                    let image = UIImageView()
                    image.sd_setImage(with: url) { (image, _, _, _) in
                        self.sender2Avatar = image
                        self.messagesCollectionView.reloadData()
                    }
                    
                }
            }
        }
    }
    var timer = Timer()
    
    var currentSenderUserAvatar:UIImage?
    var sender2Avatar:UIImage?
    var setSumaryMess:((_ mss:String)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageServer.getMessage(chatRoom_id: chatRoom_id) { (messages) in
            self.messagesData = messages
            self.messagesCollectionView.reloadData()
        }
        
        configureMessageInputBar()
        scheduledTimerWithTimeInterval()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ServerFirebase.getAvatarImageURL(user_account: userStatus.user_account) { (URL) in
            if let url = URL {
                let image = UIImageView()
                image.sd_setImage(with: url) { (image, _, _, _) in
                    self.currentSenderUserAvatar = image
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        messageServer.readMss(chatRoom_id: chatRoom_id) {
            
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }

    @objc func updateCounting(){
        NSLog("counting..")
        messageServer.getMessage(chatRoom_id: chatRoom_id) { (messages) in
            if messages.count > self.messagesData.count {
                self.messagesData = messages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    @objc
    private func getMessage(){
        messageServer.getMessage(chatRoom_id: chatRoom_id) { (messages) in
            if messages.count > self.messagesData.count {
                self.messagesData = messages
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
    }

    func currentSender() -> SenderType {
        return currentSenderUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messagesData[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesData.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if message.sender.senderId == currentSenderUser.senderId {
            avatarView.set(avatar: Avatar(image: currentSenderUserAvatar, initials: "?"))
        } else {
            avatarView.set(avatar: Avatar(image: sender2Avatar, initials: "?"))
        }
        
    }
    
}

extension MessagesVC : InputBarAccessoryViewDelegate {
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        inputBar.inputTextView.resignFirstResponder()
        
        messageServer.addNewMessage(chatRoom_id: chatRoom_id, sender: currentSenderUser, message: text) { message in
            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = "Aa"
            self.messagesData.append(message)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
}

struct Sender:SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String = ""
    var sentDate: Date
    var kind: MessageKind
}
