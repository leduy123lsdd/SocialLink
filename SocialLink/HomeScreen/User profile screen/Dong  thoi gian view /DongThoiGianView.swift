//
//  DongThoiGianView.swift
//  SocialLink
//
//  Created by Lê Duy on 5/20/21.
//

import UIKit

class DongThoiGianView: UIView, SelectNewStory {
    func newStoryLoction(location: Int) {
        
    }
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    typealias DictType = [String:Any]
    
    var storyData = [[DictType]]()
    var userStoryAvatar = [DictType]()
    var rootVC:UIViewController?
    
    let viewStoryViewController = ViewStoryViewController(nibName: "ViewStoryViewController", bundle: nil)
    var user_account = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("DongThoiGianView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(IGStoryListCell.self, forCellWithReuseIdentifier: IGStoryListCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "NoStoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoStoryCollectionViewCell")
        
        
        viewStoryViewController.viewStoryDelegate = self
        
        
    }
    
    // Get all stories of follower
    public func parseData(user_account:String,
                          completion:((_ amountOfData:Int)->Void)?=nil) {
        self.user_account = user_account
        
        userStoryAvatar.removeAll()
        
        let user = user_account
        
        searchUserService.getStory(for: user) { (dataArr) in
            self.storyData.removeAll()
            let dataNew = dataArr as! [DictType]
            
            
            if dataNew.count > 0 {
                
                var filledData = [String]()
                
                let first_time = (dataNew.first?["last_updated"] as! String)
                filledData.append(self.getDateTime(data: first_time))
                
                for data in dataNew {
                    
                    let time = data["last_updated"] as! String
                    let date = self.getDateTime(data: time)
                    
                    var existed = false
                    
                    for fill_data in filledData {
                        if fill_data == date {
                            existed = true
                            break
                        }
                    }
                    if !existed {
                        filledData.append(date)
                    }
                }
                
                
                for filledTime in filledData {
                    
                    var same_time_data = [DictType]()
                    
                    for dt in dataNew {
                        
                        let time = (dt["last_updated"] as! String)
                        let time_date = self.getDateTime(data: time)
                        
                        if time_date == filledTime {
                            same_time_data.append(dt)
                        }
                    }
                    self.storyData.append(same_time_data)
                }
                
                for str in self.storyData {
                    let data = str.first!
                    let url = data["url"] as! String
                    
                    
                    let newData:[String : Any] = ["user_account":user,
                                                  "avatarURL":url]
                    self.userStoryAvatar.append(newData)
                }
                
                completion?(self.storyData.count)
                self.collectionView.reloadData()
                
            }
            
        }
        

    }
    
    func getDateTime(data:String) -> String{
        let time = Double(data) ?? 0
        let convert_time = "\(NSDate(timeIntervalSince1970: time))"
        let string_time = convert_time.dropLast(15)
        
        return "\(string_time)"
    }

}

extension DongThoiGianView:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if storyData.count > 0 {
            return storyData.count
        } else {
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if storyData.count == 0 && indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoStoryCollectionViewCell",for: indexPath) as! NoStoryCollectionViewCell
            return cell
        }
        
        let data = self.storyData[indexPath.row]
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,
                                                            for: indexPath) as? IGStoryListCell else { fatalError() }
        
        let story_image = data.first
        let image_story_present = story_image?["url"] as! String
        
        if let story_url_image = URL(string: image_story_present) {
            cell.userDetails = ("","\(story_url_image)")
        }
        

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = storyData[indexPath.row ]
        
        viewStoryViewController.storyData = self.storyData
        viewStoryViewController.userStoryAvatar = self.userStoryAvatar
        viewStoryViewController.fetchData(datas: data)
        viewStoryViewController.dongthoigianView = true
        
        rootVC?.present(viewStoryViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if storyData.count == 0 {
            return CGSize(width: 200, height: 100)
        }
        return CGSize(width: 80, height: 100)
    }
    
}


