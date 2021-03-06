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
    let storage = Storage.storage()
    
    
    
    // MARK: - Sign up new user
    func signUpNewUser(newUser:[String:Any], success:(@escaping()->Void)){
        let user_account = newUser["user_account"] as! String
        
        db.collection("users").document(user_account).setData(newUser) { (err) in
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
                    guard let verifyAccount = document.data()["user_account"] as? String else {fatalError()}
                    guard let verifyPassword = document.data()["pass_word"] as? String else {fatalError()}
                    
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
    // MARK: Get user profile
    func getUserProfile(user_account:String, completion:((_ dataRes:[String:Any]?)->Void)?) {
        db.collection("users").document(user_account).getDocument { (res, err) in
            if let err = err {
                print(err)
            } else {
                if let comp = completion {
                    comp(res?.data())
                }
            }
        }
    }
    
    // MARK: update profile
    func updateProfile(user_account:String ,
                       display_name:String?,
                       bio:String?,
                       avatar: Data?,
                       completion:(@escaping ()->Void),
                       failed:(@escaping ()->Void)) {
        
        var newProfile = [String:Any]()
        
        if let display_name = display_name {
            if display_name != "" {
                newProfile["display_name"] = display_name
            }
        }
        
        if let bio = bio {
            if bio != "" {
                newProfile["bio"] = bio
            }
        }
        
        // Update new infor to user
        db.collection("users").document(user_account).updateData(newProfile) { error in
            if let err = error {
                print(err)
                failed()
                return
            } else {
                completion()
            }
            
        }
        
        // Update new url avatar to user account
        if let avatar = avatar {
            self.uploadProfileImage(data: avatar , user_account: userStatus.user_account, completion: nil)
            
        }
        
    }
    
    // MARK: get avatar image
    func getAvatarImageURL(user_account:String,completion:(@escaping (_ avatar_url:URL?)->Void)) {
        self.storageReference.child("avatar_images/\(user_account)").listAll { list, error in
            if let err = error {
                print("Get avatar image url error: \(err)")
            }
            self.getImagesURL_OfPost(list.items) { url in
                if url.count > 0 {
                    completion(url[0])
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    // MARK: upload profile image
    private func uploadProfileImage(data:Data,user_account:String, completion:(()->Void)?){
        let uploadRef = storage.reference(withPath:"avatar_images/\(user_account)/\(user_account).jpg")
        let imageData = data
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        uploadRef.putData(imageData, metadata: nil) { _, errorRes in
            if let err = errorRes {
                print(err)
                return
            }
            
            if let comp = completion{
                comp()
            }
            
            // Set new url avatar to user
            self.getAvatarImageURL(user_account: user_account) { urlRes in
                if let url = urlRes {
                    self.db.collection("users").document(user_account).updateData([
                        "avatarUrl":"\(url)"
                    ]) { err in
                        if let er = err {
                            print(er)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Posts listener
    func postListener(){
        db.collection("posts").document()
    }
    
    // MARK: - Create new post
    func createNewPost(newPost:[String:Any], success:(@escaping ()->Void ), failed:(@escaping ()->Void )) {
        
        let postContent:[String:Any] = [
            "post_id": newPost["post_id"]!,
            "user_account":newPost["user_account"]!,
            "caption":newPost["caption"]!,
            "amount_like":newPost["amount_like"]!,
            "liked_by_users":[Any](),
            "comments":[Any](),
            "time":Date().timeIntervalSince1970
        ]
        
        // get all followers
        let post_id = newPost["post_id"] as! String
        db.collection("users").document(userStatus.user_account).getDocument { (data, _) in
            
            guard let dataRes = data?.data() else {return}
            guard let followers = dataRes["followers"] as? [String] else {return}
            
            // send new notification for each follower
            for follower in followers {
                notificationCenterServer
                    .post_notification(user_give_notif: userStatus.user_account,
                                       user_get_notif: follower,
                                       post_id: post_id,
                                       type: "new_post")
            }
        }
          
        
        db.collection("posts").document(postContent["post_id"] as! String).setData(postContent) { (error) in
            if let err = error {
                print("error when create new post  \(err)")
                failed()
            } else {
                success()
            }
            
        }
        
        for image in (newPost["images"] as! [Data]) {
            uploadImages(data: image,post_id: newPost["post_id"]! as! String)
        }
        
        db.collection("users").document(userStatus.user_account).updateData([
            "posted_id": FieldValue.arrayUnion([(postContent["post_id"] as! String)])
        ])
        
    }
    
    // MARK: - delete post
    func deletePost(post_id:String, user_account:String,
                    compeletion:@escaping()->Void){
        // 1 xoa post id trong posted_id trong users
        db.collection("users").document(user_account).updateData([
            "posted_id": FieldValue.arrayRemove([post_id])
        ]){ error in
            if let err = error {
                print(err)
                return
            }
            
            // delete post_data:
            self.db.collection("posts").document(post_id).delete { (error) in
                if let err = error {
                    print(err)
                    return
                }
                
                self.storageReference.child("images/\(post_id)").listAll { (datasRes, _) in
                    
                    for data in datasRes.items {
                        self.storageReference.child(data.fullPath).delete()
                    }
                    
                }
                compeletion()
            }
        }
    }

    // MARK: get post by ID
    public func getPostBy_post_id(post_id:String, completion:(@escaping (_ data:[String:Any])->Void)) {
        // get post info and then get images of that post
        self.db.collection("posts").document(post_id).getDocument { dataSnap, _ in
            // This is post data
            guard var postInfo = dataSnap?.data() else {return}
            self.storageReference.child("images/\(post_id)").listAll { list, _ in
                self.getImagesURL_OfPost(list.items) { url in
                    postInfo["images_url"] = url
                    completion(postInfo)
                }
            }
        }
    }
    
    // MARK: get posts of current user.
    func getUserPost(user_account:String,
                     success:(@escaping (_ dataReturn:[String:Any])->Void ),
                     failed:@escaping ()->Void){
        /**
         Need: user_account to find all your posted_id
         Get post from friend need: user_account from friend and then do processes likes yours post.
         posted_id: for get images and addition information.
         */
        
        // get post of you:
        db.collection("users").document(user_account).getDocument { (dataSnap, error) in
            if let err = error {
                print("error at get post: \(err)")
                failed()
                return
            }
            // data response from server. Got posted_id
            guard let userInfo = dataSnap?.data() else { return }
            
            
            if let yourPosts_id = userInfo["posted_id"] as? [String] {
                
                // No post 
                if yourPosts_id.count == 0 {
                    failed()
                    return
                }
                
                // Loop through all posted_id item in array.
                for post_id in yourPosts_id {
                    // Get info and images by posted_id
                    self.getPostBy_post_id(post_id: post_id) { res in
                        success(res)
                    }
                }
            }
        }
    }
    
    // MARK: Add comment listener in realtime
    func addListenerForPostWith(post_id:String, commentsResponse:@escaping (_ res:[String:Any])->Void){
        db.collection("posts").document(post_id).addSnapshotListener { (documentSnap, err) in
            if let document = documentSnap,
               let data = document.data() {
                commentsResponse(data)
            }
        }
    }
    
    // MARK: Like update
    func newLike(from user:[String:Any], completion:(@escaping(_ data:[Any])->Void)) {
        // user give like
        let user_account = user["user_account"] as! String
        // user get like
        let get_like_user = user["get_like_user"] as! String
        let post_id = user["post_id"] as! String
        var alreadyLike = false
        
        getLikedUsers(post_id: post_id) { (users) in
            for user in users as! [Any] {
                if (user as! String) == userStatus.user_account {
                    alreadyLike = true
                    break
                }
            }
            if !alreadyLike {
                // Make new like
                self.db.collection("posts").document("\(post_id)").updateData([
                    "liked_by_users":FieldValue.arrayUnion([user_account])
                ])
                
                if get_like_user != user_account {
                    // Alert for that user
                    notificationCenterServer.post_notification(user_give_notif: user_account,
                                                               user_get_notif: get_like_user,
                                                               post_id: post_id,
                                                               type: "like_post")
                }
                
                
            } else {
                self.db.collection("posts").document("\(post_id)").updateData([
                    "liked_by_users":FieldValue.arrayRemove(["\(user_account)"])
                ])
            }
            self.updateLikeStatus(post_id: post_id) { (res) in
                completion(res)
            }
        }
    }
    
//    private func unlike(from user:[String:Any]){
//        let user_account = user["user_account"] as! String
//        let post_id = user["post_id"] as! String
//
//        db.collection("posts").document("\(post_id)").updateData([
//            "liked_by_users":FieldValue.arrayRemove(["\(user_account)"])
//        ])
//    }
    
    func updateLikeStatus(post_id:String, completion:(@escaping(_ data:[Any])->Void)) {
        db.collection("posts").document("\(post_id)").getDocument { (snap, _) in
            if let userLike = snap?.data() {
                completion(userLike["liked_by_users"] as! [Any])
            }
        }
    }
    
    private func getLikedUsers(post_id:String,completion:(@escaping( _ data: Any)->Void)){
        db.collection("posts").document("\(post_id)").getDocument { snap, error in
            if let err = error {
                print(err)
            } else {
                guard let liked_users = snap?.data()?["liked_by_users"] else { return }
                completion(liked_users)
            }
            
        }
    }
    
    // MARK: - Support functions (not use this)
    private func uploadImages (data:Data,post_id:String){
        let randomId = UUID.init().uuidString
        let uploadRef = storage.reference(withPath:"images/\(post_id)/\(randomId).jpg")
        let imageData = data
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        uploadRef.putData(imageData)
    }
    
    private func getImagesURL_OfPost(_ urlRaw:[Any],completion:@escaping (_ data:[URL])->Void){
        var responseData = [URL]() {
            didSet {
                if responseData.count == urlRaw.count {
                    completion(responseData)
                }
            }
        }
        
        for url in urlRaw {
            storage.reference(forURL: "\(url)").downloadURL { url,_ in
                guard let urlFetched = url else {return}
                responseData.append(urlFetched)
            }
        }
    }
    
    // MARK: - Make a comment
    
    func getComments(postId:String, responseData:(@escaping(_ data:[[String:Any]])->Void)){
        db.collection("post_comments").document(postId).collection("comments").getDocuments { snap, _ in
            var dataResponse = [[String:Any]]()
            if let documents = snap?.documents {
                for document in documents {
                    dataResponse.append(document.data())
                }
                responseData(dataResponse)
            }
        }
        
        
    }
    
    func uploadComment(post_id:String ,newComment:[String:Any],completion:@escaping()->Void) {
        let comment_id = newComment["comment_id"] as! String
        
        db.collection("post_comments").document(post_id).collection("comments").document(comment_id).setData(newComment) { err in
            if let er = err {
                print(er)
            } else {
                completion()
            }
        }
    }
    
    func deleteComment(comment_id:String, at postId:String, completion:@escaping()->Void) {
        db.collection("post_comments").document(postId).collection("comments").document(comment_id).delete() { _ in
            completion()
            // Remove all replies of comment
            self.db.collection("comment_replies").document(comment_id).delete()
        }
    }
    
    func like_unlike_comment(comment_id:String, postId:String, fromUser:String, completion:@escaping(_ data:[String:Any])->Void) {
        let commentRef = db.collection("post_comments").document(postId).collection("comments").document(comment_id)
        
        commentRef.getDocument { (data, _) in
            guard let dataRes = data?.data() else {return}
            guard let listUsersLiked = dataRes["liked_by_users"] as? [String] else {return}
            
            // Check user like or not like the reply
            var liked = false
            
            for user in listUsersLiked {
                if user == userStatus.user_account {
                    liked = true
                    break
                }
            }
            
            commentRef.updateData([
                "liked_by_users":(liked ? FieldValue.arrayRemove(["\(fromUser)"]) : FieldValue.arrayUnion([fromUser]))
            ]) { error in
                if let err = error {
                    print(err)
                    return
                }
                
                commentRef.getDocument { (data, _) in
                    if let dt = data?.data() {
                        completion(dt)
                    }
                }
                
            }
        }
    }
    
    // MARK: - Reply comment
    
    func getMultipReply(comment_id:String, completion:@escaping(_ data:[Any])->Void){
        db.collection("comment_replies").document(comment_id).collection("replies").getDocuments { (snap, error) in
            var replies = [[String:Any]]()
            if let data = snap?.documents {
                for doc in data {
                    replies.append(doc.data())
                }
                completion(replies)
            }
            
        }
    }
    
//    func replies(comment_id:String, completion:@escaping(_ data:[[String:Any]])->Void){
//        db.collection("comment_replies").document(comment_id).collection("replies").getDocuments { data, _ in
//
//            var replies = [[String:Any]]()
//
//            if let dt = data?.documents {
//                for doc in dt {
//                    replies.append(doc.data())
//                }
//                completion(replies)
//            }
//        }
//    }

    func uploadReplyToComment(newReply:[String:Any], comment_id:String, completion:@escaping ()->Void) {
        let reply_id = newReply["reply_id"] as! String
        
        
        db.collection("comment_replies").document(comment_id).collection("replies").document(reply_id).setData(newReply) { _ in
            completion()
        }
    }
    
    func deleteReply(comment_id:String, reply_id:String,completion:@escaping()->Void) {
        db.collection("comment_replies").document(comment_id).collection("replies").document(reply_id).delete() {_ in
            completion()
        }
    }
    
    func getOneReply(comment_id:String, reply_id:String,completion:@escaping(_ data:[String:Any])->Void) {
        db.collection("comment_replies").document(comment_id).collection("replies").document(reply_id).getDocument { data, _ in
            if let dt = data?.data() {
                completion(dt)
            }
        }
    }
    
    func like_unlike_Reply(comment_id:String, reply_id:String,fromUser:String,likeComp:@escaping(_ data:[String:Any])->Void) {
        let refToReply = db.collection("comment_replies").document(comment_id).collection("replies").document(reply_id)
        
        // Danh sach nguoi da like
        refToReply.getDocument { (dataSnap, _) in
            guard let data = dataSnap?.data() else {return}
            guard let listUsersLiked = data["liked_by_users"] as? [String] else {return}
            
            // Check user like or not like the reply
            var liked = false
            
            for user in listUsersLiked {
                if user == userStatus.user_account {
                    liked = true
                    break
                }
            }
            
            // Like the reply
            refToReply.updateData([
                "liked_by_users":(liked ? FieldValue.arrayRemove(["\(fromUser)"]) : FieldValue.arrayUnion([fromUser]))
            ]) { error in
                if let err = error {
                    print(err)
                } else {
                    ServerFirebase.getOneReply(comment_id: comment_id, reply_id: reply_id) { data in
                        likeComp(data)
                    }
                }
            }
            
            
            
        }
    }
    
    
    // MARK: - realtime update post
    func listenerPosts(user_account:String,
                       action:@escaping()->Void){
        db.collection("users").document(user_account).addSnapshotListener { (dataSnap, error) in
            print("updated post from \(user_account)")
            action()
            
            
        }
    }
}
