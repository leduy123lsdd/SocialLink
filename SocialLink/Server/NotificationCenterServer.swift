//
//  NotificationCenterServer.swift
//  SocialLink
//
//  Created by Lê Duy on 5/20/21.
//

import Foundation
import Firebase

let notificationCenterServer = NotificationCenterServer()

class NotificationCenterServer {
    private let db = Firestore.firestore()
    
    // push like_post_notification
    public func post_notification(user_give_notif:String,
                                  user_get_notif:String,
                                  post_id:String,
                                  type:String){
        let notif_id = "\(Date().timeIntervalSince1970)"
        db.collection("notifications").document(user_get_notif).collection("queue").document(notif_id).setData([
            "user_like": user_give_notif,
            "post_id": post_id,
            "notif_id":notif_id,
            "time": notif_id,
            "type":type,
            "seen":"false",
            "user_get_notif":user_get_notif
        ])
    }
    
    public func seen_post_notifi(notif_id:String,
                                 user_give_like:String,
                                 user_get_like:String,
                                 post_id:String,
                                 completion:@escaping()->Void) {
        db.collection("notifications")
            .document(user_get_like)
            .collection("queue")
            .document(notif_id)
            .updateData([
                "seen":"true"
            ]) { (Error) in
                if let error = Error {
                    print(error)
                    return
                }
                completion()
            }
    }
    
    // get like_post_notification
    public func get_notification(user_account:String,
                                 completion:@escaping(_ dataRes:[[String:Any]])->Void,
                                 failed:@escaping()->Void){
        db.collection("notifications")
            .document(user_account)
            .collection("queue")
            .getDocuments { (QuerySnapshot, Error) in
                if let error = Error {
                    print(error)
                    failed()
                    return
                }
                
                
                guard let dataRes = QuerySnapshot?.documents else {
                    failed()
                    return
                }
                
                var dataReturn = [[String:Any]]()
                
                for data in dataRes {
                    dataReturn.append(data.data())
                }
                completion(dataReturn)
            }
    }
    
    
}
