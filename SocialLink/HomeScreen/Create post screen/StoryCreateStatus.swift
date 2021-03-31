//
//  StoryCreateStatus.swift
//  SocialLink
//
//  Created by Lê Duy on 3/27/21.
//

import UIKit
import ProgressHUD
import YPImagePicker

class StoryCreateStatus: UIViewController {
    
    var pickedImages:[UIImage]?
    @IBOutlet var caption: UITextField!
    
    var pickerViewRoot:YPImagePicker?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        caption.layer.borderWidth = 0
        caption.layer.borderColor = UIColor.clear.cgColor
        
        self.navigationItem.title = "Content"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareTapped))
    }
    
    @objc func shareTapped(){
        
        ProgressHUD.show()
        
        guard let images = pickedImages else { return }
        
        // Convert UIImage to Jpeg image file.
        var imagesData = [Data]()
        for im in images {
            guard let data = im.jpegData(compressionQuality: 0.4) else { return }
            imagesData.append(data)
        }
        
        // New post data
        let newPost:[String:Any] = [
            "post_id": UUID().uuidString,
            "user_name":userStatus.user_name,
            "caption":caption.text ?? "",
            "amount_like":0,
            "images":imagesData
        ]
        
        
        // Push to server.
        ServerFirebase.createNewPost(newPost: newPost) {
            ProgressHUD.showSucceed()
        } failed: {
            ProgressHUD.showFailed()
        }
        
        pickedImages?.removeAll()
        caption.text = ""
        
        self.dismiss(animated: true) {
            self.pickerViewRoot?.dismiss(animated: false, completion: nil)
        }
    }
    
}

struct Comment {
    var user_comment:String?
    var comment_content:String?
    var reply:[Reply]?
}

struct Reply {
    var user_reply:String?
    var reply_content:String?
}
