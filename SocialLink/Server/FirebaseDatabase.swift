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
    
    private let db = Firestore.firestore()
    
    
    func setValue(data:[String:Any]){
    }
    
    /**
      new user data form:
        display_name
        pass_word
        user_account
     */
    func signUpNewUser(newUser:[String:Any], success:(@escaping()->Void)){
        ref = db.collection("users").addDocument(data: newUser) { err in
            if let err = err {
                print("error when add new data: \(err)")
            } else {
                print("add new data success")
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
}
