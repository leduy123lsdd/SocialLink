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
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    @IBOutlet var captionTextView: UITextView!
    
    // Setup view
    private func setupView(){
        captionTextView.delegate = self
        captionTextView.text = "Write a caption..."
        captionTextView.textColor = UIColor.lightGray
        
        
        self.navigationItem.title = "Content"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareTapped))
    }
    
    // MARK: - Share button action
    @objc func shareTapped(){
        ProgressHUD.show()
        
        guard let images = pickedImages else { return }
    
        // Convert UIImage to Jpeg image file.
        var imagesData = [Data]()
        for im in images {
            guard let data = im.jpegData(compressionQuality: 0.2) else { return }
            imagesData.append(data)
        }
        
        // New post data
        let newPost:[String:Any] = [
            "post_id": UUID().uuidString,
            "user_account":userStatus.user_account,
            "caption":captionTextView.text ?? "",
            "amount_like":0,
            "images":imagesData
        ]
        
        // Push post to server.
        ServerFirebase.createNewPost(newPost: newPost) {
            ProgressHUD.showSucceed()
        } failed: {
            ProgressHUD.showFailed()
        }
        
        // clear old data after user share the post
        pickedImages?.removeAll()
        captionTextView.text = nil
        
        self.dismiss(animated: true) {
            self.pickerViewRoot?.dismiss(animated: false, completion: nil)
        }
    }
    
}

extension StoryCreateStatus: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if captionTextView.text.isEmpty {
            captionTextView.text = "Write a caption..."
            captionTextView.textColor = UIColor.lightGray
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if captionTextView.textColor == UIColor.lightGray {
            captionTextView.text = nil
            captionTextView.textColor = UIColor.black
        }
    }
}
