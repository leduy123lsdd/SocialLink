//
//  FirebaseDatabase.swift
//  SocialLink
//
//  Created by Lê Duy on 3/23/21.
//

import Foundation
//import FirebaseDatabase
import Firebase

let ServerFirebase = FirebaseDatabase()

class FirebaseDatabase {
    private let database = Firebase.fire
    
    
    func setValue(data:[String:Any]){
        database.child("something").setValue(data)
        
        
        
    }
}
