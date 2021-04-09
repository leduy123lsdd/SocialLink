//
//  HomeViewController.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit
import YPImagePicker

class HomeViewController: UIViewController {
    
    @IBOutlet weak var scrollContainer: UIView!
    
    let storyVC = StoryVC(nibName: "StoryVC", bundle: nil)
    let searchUserVC = SearchUserVC(nibName: "SearchUserVC", bundle: nil)
    let createPostVC = CreatePostVC(nibName: "CreatePostVC", bundle: nil)
    let userProfileVC = UserProfileVC(nibName: "UserProfileVC", bundle: nil)
    let storyCreateStatus = StoryCreateStatus(nibName: "StoryCreateStatus", bundle: nil)
    
    var pagesVC = [UIViewController]()
    var config = YPImagePickerConfiguration()
    var picker:YPImagePicker!
    
    var postsData = [String:Any]()
    
    // MARK: Buttons functions
    @IBAction func homeBtnClicked(_ sender: Any) {
        setViewController(index: 0)
    }
    
    @IBAction func searchUserBtnClicked(_ sender: Any) {
        setViewController(index: 1)
        self.view.bringSubviewToFront(pagesVC[1].view)
    }
    
    @IBAction func createPostClicked(_ sender: Any) {
        
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
            
            self.storyCreateStatus.pickedImages = pickedImages
            self.storyCreateStatus.pickerViewRoot = picker
            
            
            picker!.pushViewController(self.storyCreateStatus, animated: true)
        }
        
        
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func userProfileClicked(_ sender: Any) {
        setViewController(index: 3)
        // log out
//        userStatus = UserStatus()
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
    }()
    
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        storyVC.rootVC = self
        
        pagesVC = [storyVC,searchUserVC,createPostVC,userProfileVC]
        setupPageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupPageViewController() {
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.pageViewController.view.frame = .zero
        
        pageViewController.setViewControllers([pagesVC[0]], direction: .forward, animated: false, completion: nil)
        self.addChild(self.pageViewController)
        
        self.scrollContainer.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewController.view.topAnchor.constraint(equalTo: self.scrollContainer.topAnchor).isActive = true
        self.pageViewController.view.leftAnchor.constraint(equalTo: self.scrollContainer.leftAnchor).isActive = true
        self.pageViewController.view.bottomAnchor.constraint(equalTo: self.scrollContainer.bottomAnchor).isActive = true
        self.pageViewController.view.rightAnchor.constraint(equalTo: self.scrollContainer.rightAnchor).isActive = true
        
        
        config.library.maxNumberOfItems = 5
        config.usesFrontCamera = true
        config.screens = [.photo,.library]
        
    }

    private func setViewController(index:Int = 0){
        let direction:UIPageViewController.NavigationDirection = {
            if index <= 3 {
                return .forward
            }
            else {
                return .reverse
            }
        }()
        self.pageViewController.setViewControllers([pagesVC[index]], direction: direction, animated: false, completion: nil)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

}

extension HomeViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
    
    
}
