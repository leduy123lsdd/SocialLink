//
//  SearchUserService.swift
//  SocialLink
//
//  Created by Lê Duy on 5/8/21.
//

import Foundation
import Firebase

let searchUserService = SearchUserService()

class SearchUserService {
    private var ref: DocumentReference? = nil
    private let db = Firestore.firestore()
    private let storageReference = Storage.storage().reference()
    let storage = Storage.storage()
    
    // MARK: - Get all user 
    func getAllUsers(completion:(@escaping(_ data: [[String:Any]])->Void)){
        let userRef = db.collection("users")
        userRef.getDocuments { dataRes, error in
            if let err = error {
                print(err)
                return
            }
            
            var dataReturn = [[String:Any]]()
            
            guard let data = dataRes?.documents else {return}
            
            for dt in data {
                let temp = dt.data() as [String:Any]
                dataReturn.append(temp)
            }
            
            completion(dataReturn)
        }
    }
}
    
