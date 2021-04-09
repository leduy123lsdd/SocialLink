//
//  MainContentCell.swift
//  SocialLink
//
//  Created by Lê Duy on 3/20/21.
//

import UIKit
import ImageSlideshow

class MainContentCell: UITableViewCell {
    
    var rootVC:UIViewController?
    
//    @IBOutlet var avatarImage: UIImageView!
//    @IBOutlet var userName: UILabel!
//    @IBOutlet var uploadTime: UILabel!
    // test image
    let localSource = [BundleImageSource(imageString: "im1"), BundleImageSource(imageString: "im2"), BundleImageSource(imageString: "im3"), BundleImageSource(imageString: "im4")]
    @IBOutlet var slideshow: ImageSlideshow!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        setupSlideShow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
    }
    
    private func setupUI(){
        
    }
    
    private func setupSlideShow(){
        // Position of page indicator
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customUnder(padding: 0))
        
        // Scale for images
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // Indicator color ..
        let pageIndicator = UIPageControl()
        pageIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        pageIndicator.currentPageIndicatorTintColor = UIColor.systemTeal
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        pageIndicator.backgroundColor = UIColor.clear
        
        slideshow.pageIndicator = pageIndicator
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator(style: .large, color: .green)
        slideshow.delegate = self

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(localSource)
    }
    
    
    @IBAction func addComment(_ sender: Any) {
        if let rootVC = rootVC {
            let addComment = MakeCommentVC(nibName: "MakeCommentVC", bundle: nil)
            
            rootVC.navigationController?.pushViewController(addComment, animated: true)
        }
    }
    
}


extension MainContentCell: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
