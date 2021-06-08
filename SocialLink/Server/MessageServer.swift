//
//  MessageServer.swift
//  SocialLink
//
//  Created by Lê Duy on 5/27/21.
//

import Foundation

import MessageKit
import Firebase

let messageServer = MessageServer()

class MessageServer {
    private let db = Firestore.firestore()
    private let storageReference = Storage.storage().reference()
    let storage = Storage.storage()
    
    public func findChatRoomForUsers(user1:String,
                                     user2:String,
                                     completion:(@escaping(_ chatRoom_id:String?)->Void)){
        db.collection("chatRooms").getDocuments { (dataRes, _) in
            guard let data = dataRes else {return}
            
            for document in data.documents {
                let chatRoom_id = document.documentID
                
                if chatRoom_id.contains(user1) && chatRoom_id.contains(user2) {
                    completion(chatRoom_id)
                    return
                }
            }
            
            completion(nil)
        }
        
    }
    
    public func getChatRoomsFor(user:String,
                                completion:@escaping(_ chatRooms:[[String:Any]]) -> Void ) {
        
        db.collection("chatRooms").getDocuments { dataRes, _ in
            guard let data = dataRes else {return}
            
            var chatRooms = [[String:Any]]()
            
            for document in data.documents {
                let chatRoom_id = document.documentID
                
                if chatRoom_id.contains(user) {
                    chatRooms.append(document.data())
                }
                
            }
            
            completion(chatRooms)
        }
        
    }
    
    public func makeNewChatRoom(user1:String,
                                user2:String,
                                completion:(@escaping(_ chatRoom_id:String)->Void)) {
        let chatRoom_id = "\(user1)_\(user2)"
        let ref = db.collection("chatRooms").document(chatRoom_id)
        
        let data = [
            "chatRoom_id":chatRoom_id,
            "user1": user1,
            "user2": user2,
            "read":"false"
        ]
        
        ref.setData(data) { Error in
            
            if let error = Error {
                print(error)
            } else {
                completion(chatRoom_id)
            }
        }
        
    }
    
    public func getMessage(chatRoom_id:String,
                           completion:((_ messages:[Message])->Void)? = nil){
        let ref = db.collection("chatRooms").document(chatRoom_id).collection("messages")
        
        ref.getDocuments { messagesSnap, _ in
            guard let messages = messagesSnap else {return}
            
            var messageReturn = [Message]()
            
            for mess in messages.documents {
                let messData = mess.data()
                
                let sender = messData["sender"] as! String
                let display_name = messData["display_name"] as! String
                
                let senderType = Sender(senderId: sender, displayName: display_name)
                let sentDate = Double(messData["sentDate"] as! NSNumber)
                let message_id = messData["message_id"] as! NSNumber
                let messageString = messData["message"] as! String
                
                let message = Message(sender: senderType,
                                      messageId: "\(message_id)",
                                      sentDate: Date(timeIntervalSince1970: sentDate),
                                      kind: .text(messageString))
                messageReturn.append(message)
            }
            
            completion?(messageReturn)
        }
    }
    
    public func readMss(chatRoom_id:String, comp:@escaping()->Void){
        db.collection("chatRooms").document(chatRoom_id).updateData(["read":"true"]){ (_) in
            comp()
        }
        
    }
    
    public func addNewMessage(chatRoom_id:String,
                              sender: Sender,
                              message: String,
                              completion:((_ message:Message)->Void)?){
        
        let message_id = Date().timeIntervalSince1970
        let dataNew: [String:Any] = [
            "sender": sender.senderId,
            "display_name": sender.displayName,
            "sentDate": message_id,
            "message_id":message_id,
            "message": message
        ]
        
        db.collection("chatRooms").document(chatRoom_id).updateData(["read":"false"])
        
        
        db.collection("chatRooms").document(chatRoom_id).collection("messages")
            .document("\(message_id)").setData(dataNew) { _ in
                
                let message = Message(sender: sender,
                                      messageId: "\(message_id)",
                                      sentDate: Date(timeIntervalSince1970: message_id),
                                      kind: .text(message))
                completion?(message)
            }
        
    }
    
    public func observerForMessage(){
        
    }
}

