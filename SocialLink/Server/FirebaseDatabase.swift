//
//  FirebaseDatabase.swift
//  SocialLink
//
//  Created by Lê Duy on 3/23/21.
//

import Foundation
import Firebase


let ServerFirebase = FirebaseDatabase()

class FirebaseDatabase {
    var ref: DocumentReference? = nil
//    let storageRef = Storage.storage().reference()
    
    private let db = Firestore.firestore()
    
    /**
      new user data form:
        display_name
        pass_word
        user_account
     */
    func signUpNewUser(newUser:[String:Any], success:(@escaping()->Void)){
        db.collection("users").addDocument(data: newUser) { err in
            if let err = err {
                print("error when add new user: \(err)")
            } else {
                print("add new user success")
                success()
            }
        }
    }
    
    func userLogin(_ account:String,_ password:String, loginSuccess:(@escaping ()->Void ), loginFailed:(@escaping ()->Void ) ){
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let verifyAccount = document.data()["user_account"] as! String
                    let verifyPassword = document.data()["pass_word"] as! String
                    
                    if account == verifyAccount && password == verifyPassword {
                        loginSuccess()
                        return
                    }
                }
                loginFailed()
            }
        }
        
    }
    
    func createNewPost(newPost:[String:Any], success:(@escaping ()->Void ), failed:(@escaping ()->Void )) {
        let postContent:[String:Any] = [
            "post_id": newPost["post_id"]!,
            "user_name":newPost["user_name"]!,
            "caption":newPost["caption"]!,
            "amount_like":newPost["amount_like"]!
        ]
        let images = [
            "images":newPost["images"]!
        ]
        
        
        db.collection("posts").addDocument(data: postContent) { (error) in
            if let err = error {
                print("error when create new post  \(err)")
            } else {
                success()
                return
            }
            failed()
        }
        
        db.collection("postImages").document("\(newPost["post_id"]!)").setData(images) { (error) in
            if let err = error {
                print(err)
            }
        }
    }
    
    func uploadImages(imagesData:Data,post_id:String , success:(@escaping ()->Void ), failed:(@escaping ()->Void )){
        let data = imagesData
        let imageRef =
    }
}
