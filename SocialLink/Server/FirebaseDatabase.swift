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
    private var ref: DocumentReference? = nil
    private let db = Firestore.firestore()
    
    // MARK: - Sign up new user
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
    
    // MARK: - Login server
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
    
    // MARK: - Create new post
    func createNewPost(newPost:[String:Any], success:(@escaping ()->Void ), failed:(@escaping ()->Void )) {
        let postContent:[String:Any] = [
            "post_id": newPost["post_id"]!,
            "user_name":newPost["user_name"]!,
            "caption":newPost["caption"]!,
            "amount_like":newPost["amount_like"]!
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
        
        for image in (newPost["images"] as! [Data]) {
            uploadImages(data: image,post_id: newPost["post_id"]! as! String)
        }
        
    }

    // MARK: - Support functions (not use this)
    private func uploadImages (data:Data,post_id:String){
        let randomId = UUID.init().uuidString
        let uploadRef = Storage.storage().reference(withPath:"images/\(post_id)/\(randomId).jpg")
        
        let imageData = data
        
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        uploadRef.putData(imageData)

        
    }
}
