//
//  SubStoryCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/20/21.
//

import UIKit
import YPImagePicker

class SubStoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var rootVC:UIViewController?
    
    let storyData = ["doc","cat","bird","mouse","banana","mango"]
    var config = YPImagePickerConfiguration()
    var picker:YPImagePicker!
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "StoryCell", bundle: nil), forCellWithReuseIdentifier: "StoryCell")
        collectionView.register(UINib(nibName: "AddStoryCell", bundle: nil), forCellWithReuseIdentifier: "AddStoryCell")
        
        config.library.maxNumberOfItems = 1
        config.usesFrontCamera = true
        config.screens = [.photo,.library]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStoryCell", for: indexPath) as! AddStoryCell
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCell
        cell.fillData(image: nil, name: storyData[indexPath.row-1])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80.0, height: 100.0)
    }
    
    
    
    // MARK: Select a story
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            var pickedImages = [UIImage]()
            picker = YPImagePicker(configuration: config)
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                if cancelled {
                    picker?.dismiss(animated: true, completion: nil)
                    return
                }
                
                for item in items {
                    switch item {
                    case .photo(let photo):
                        pickedImages.append(photo.image)
                    case .video(let video):
                        print(video)
                    }
                }
                
                picker?.dismiss(animated: true, completion: {
                    
                })
            }

            rootVC?.present(picker, animated: true, completion: nil)
        }
        
    }
}
