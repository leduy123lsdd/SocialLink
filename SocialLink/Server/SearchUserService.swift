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
    
    // MARK: - Get all friend belong to user_account
    func getFriends(user_account:String,
                    completion:(@escaping()->Void)){
        
    }
    
    // MARK: - Follow user, unfollow
    /**
     Two job to work, 1: go to your profile, add that friend to following list,  2: go to friend which you follow , add your self into followers list.
     */
    func followUser(follow_user:String,
                    current_user:String,
                    completion:@escaping() -> Void) {
        
        let userRef = db.collection("users")
        
        // job 1
        userRef.document(current_user).updateData([
            "following": FieldValue.arrayUnion([follow_user])
        ]) { _ in
            
            // job 2
            userRef.document(follow_user).updateData([
                "followers":FieldValue.arrayUnion([current_user])
            ]) { _ in
                completion()
            }
            
        }
        
    }
    
    func unfollow(follow_user:String,
                  current_user:String,
                  completion:@escaping() -> Void){
        let userRef = db.collection("users")
        
        // job 1
        userRef.document(current_user).updateData([
            "following": FieldValue.arrayRemove([follow_user])
        ]) { _ in
            // job 2
            userRef.document(follow_user).updateData([
                "followers":FieldValue.arrayRemove([current_user])
            ]) { _ in
                completion()
            }
        }
        
        
    }
    
    
    // MARK: - upload new story
    func uploadStory(image:UIImage,
                     user_account:String,
                     completion:(@escaping()->Void),
                     failed:(@escaping()->Void)){
        
        let created_time = Date().timeIntervalSince1970
        let storyID = "\(user_account)\(created_time)"
        var uploadData:[String:Any] = [
            "user_account":user_account,
            "story_id":storyID,
            "time":"\(created_time)"
        ]
        
        let storyRef = db.collection("user_stories").document(user_account).collection("stories").document(storyID)
        
        if let image_data = image.jpegData(compressionQuality: 0.5) {
            
            uploadImages(data: image_data, story_id: storyID) { image_link in
                
                self.storageReference.child(image_link ?? "").downloadURL { url, err in
                    if let URL = url {
                        uploadData["image_url"] = "\(URL)"
                        
                        storyRef.setData(uploadData) { error in
                            if let err = error {
                                print(err)
                                failed()
                                return
                            }
                            completion()
                        }
                    }
                    
                }
            }
        }
    
    }
    // MARK: - delete story
    // delete story in fire_storage and image in storage
    func deleteStory(user_account:String,
                     story_id:String,
                     completion:(@escaping()->Void)){
        
        let path_image = "user_stories/\(user_account)/\(story_id)"
        
        let infor_story_path = db.collection("user_stories")
            .document(user_account)
            .collection("stories")
            .document(story_id)
        
        // Delete image in storage
        storageReference.child(path_image).delete { (error) in
            if let err = error {
                print(err)
                return
            }
            
            // Delete story info
            infor_story_path.delete { (error) in
                if let err = error {
                    print(err)
                    return
                }
                completion()
            }
        }
    }
    
    // MARK: - get stories, return all stories of that user :p
    func getStory(for user_account:String,
                  completion:(@escaping(_ data:[Any])->Void)) {
        
        let storyRef = db.collection("user_stories")
            .document(user_account)
            .collection("stories")
        
        storyRef.getDocuments { (dataSnap, error) in
            if let err = error {
                print(err)
                return
            }
            
            if let data = dataSnap {
                var dataReturn = [Any]()
                for doc in data.documents {
                    dataReturn.append(doc.data())
                }
                completion(dataReturn)
            }
        }
    }
    
    
    private func uploadImages (data:Data,
                               story_id:String,
                               completion:(@escaping(_ image_link:String?)->Void)){
        let uploadRef = storage.reference(withPath:"user_stories/\(userStatus.user_account)/\(story_id)/\(story_id).jpg")
        let imageData = data
        
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        uploadRef.putData(imageData, metadata: uploadMetadata) { (metadata, err) in
            if let error = err {
                print(error)
                
            } else {
                if let mtdata = metadata,let name = mtdata.name {
                    let full_path = "user_stories/\(userStatus.user_account)/\(story_id)/\(name)"
                    print(full_path)
                    completion(full_path)
                }
            }
        }
    }
}
    
