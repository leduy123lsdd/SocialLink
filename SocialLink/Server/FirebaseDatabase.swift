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
    private let storageReference = Storage.storage().reference()
    
    var delegate:UpdateNewDataDelegate?
    
    // MARK: - Sign up new user
    func signUpNewUser(newUser:[String:Any], success:(@escaping()->Void)){
        db.collection("users").document(newUser["user_account"] as! String).setData(newUser) { (err) in
            if let err = err {
                print("error when add new user: \(err)")
            } else {
                print("add new user success")
                success()
            }
        }
    }
    
    // MARK: - Login server
    func userLogin(_ account:String,_ password:String, loginSuccess:(@escaping (_ userInfo:[String:Any])->Void ), loginFailed:(@escaping ()->Void ) ){
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let verifyAccount = document.data()["user_account"] as! String
                    let verifyPassword = document.data()["pass_word"] as! String
                    
                    if account == verifyAccount && password == verifyPassword {
                        loginSuccess(document.data())
                        return
                    }
                }
                loginFailed()
            }
        }
        
        db.collection("users").getDocuments { (snap, _) in
            if let snapshot = snap {
                for document in snapshot.documents {
                    print("Document ID is: \n")
                    print(document.documentID)
                }
                
            }
        }
        
    }
    
    // MARK: - Create new post
    func createNewPost(newPost:[String:Any], success:(@escaping ()->Void ), failed:(@escaping ()->Void )) {
        let postContent:[String:Any] = [
            "post_id": newPost["post_id"]!,
            "user_account":newPost["user_account"]!,
            "caption":newPost["caption"]!,
            "amount_like":newPost["amount_like"]!
        ]
        
        db.collection("posts").document(postContent["post_id"] as! String).setData(postContent) { (error) in
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
        
        db.collection("users").document(userStatus.user_account).updateData([
            "posted_id": FieldValue.arrayUnion([(postContent["post_id"] as! String)])
        ])
        
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
    
    // MARK: get posts
    func getPost(success:(@escaping (_ dataReturn:[String:Any])->Void ), failed:(@escaping ()->Void )){
        /**
         Need: user_account to find all your posted_id
         Get post from friend need: user_account from friend and do like yours post.
         posted_id: for get images and addition information.
         */
        
        // get post of you:
        db.collection("users").document(userStatus.user_account).getDocument { (dataSnap, error) in
            if let err = error {
                print("error at get post: \(err)")
                failed()
                return
            }
            // data response from server. Got posted_id
            guard let userInfo = dataSnap?.data() else { fatalError() }
            
            if let yourPosts_id = userInfo["posted_id"] as? [String] {
                // Loop through all posted_id item in array.
                for post_id in yourPosts_id {
                    // Get info (like caption blabla)
                    
                    self.getPostBy_post_id(post_id: post_id) { res in
                        self.delegate?.newPostUpdated(post: res)
                    }
                    // Get images
//                    self.db
                }
            }
                
            success(userInfo)
            
        }
    }
    
    
    private func getPostBy_post_id(post_id:String, completion:(@escaping (_ data:[String:Any])->Void)) {
        // get post info and then get images of that post
        self.db.collection("posts").document(post_id).getDocument { dataSnap, _ in
            // This is post data
            guard var postInfo = dataSnap?.data() else {fatalError()}
            self.storageReference.child("images/\(post_id)").listAll { list, _ in
                postInfo["images_url"] = list.items
                completion(postInfo)
            }
        }
    }
    
}

protocol UpdateNewDataDelegate {
    func newPostUpdated(post:[String:Any])
}


