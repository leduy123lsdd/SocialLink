//
//  HomeViewController.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit
import YPImagePicker

class HomeViewController: UIViewController,UIPageViewControllerDelegate {
    
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var postBtn: UIButton!
    @IBOutlet var notifBtn: UIButton!
    @IBOutlet var profileBtn: UIButton!
    
    
    @IBOutlet var homeIndicator: UIView!
    @IBOutlet var searchIndicator: UIView!
    @IBOutlet var postIndicator: UIView!
    @IBOutlet var notifIndicator: UIView!
    @IBOutlet var profileIndicator: UIView!
    @IBOutlet weak var scrollContainer: UIView!
    
    // .fill   magnifyingglass.circle.fill magnifyingglass.circle
    var iconName = ["house",
                    "magnifyingglass.circle",
                    "plus.app",
                    "bell",
                    "person.circle"]
    var indicator:[UIView]? = nil
    var btnOptions:[UIButton]? = nil
    
    let storyVC = StoryVC(nibName: "StoryVC", bundle: nil)
    let searchUserVC = SearchUserVC(nibName: "SearchUserVC", bundle: nil)
    let createPostVC = CreatePostVC(nibName: "CreatePostVC", bundle: nil)
    let userProfileVC = UserProfileVC(nibName: "UserProfileVC", bundle: nil)
    let storyCreateStatus = StoryCreateStatus(nibName: "StoryCreateStatus", bundle: nil)
    
    var pagesVC = [UIViewController]()
    var config = YPImagePickerConfiguration()
    var picker:YPImagePicker!
    
    var postsData = [String:Any]()
    
    lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
    
    var currentViewIndex = 0
    
    var doubleTapValue = true

    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        storyVC.rootVC = self
        
        storyVC.doubleTapIndicatorDisappear = {
            self.doubleTapValue = false
        }
        
        storyVC.doubleTapIndicatorAappear = {
            self.doubleTapValue = true
        }
        
        searchUserVC.rootVC = self 
        
        userProfileVC.rootView = self
        
        pagesVC = [storyVC,searchUserVC,createPostVC,userProfileVC]
        
        indicator = [homeIndicator,
                     searchIndicator,
                     postIndicator,
                     notifIndicator,
                     profileIndicator]
        
        btnOptions = [homeBtn,
                     searchBtn,
                     postBtn,
                     notifBtn,
                     profileBtn]
        
        indicator?.forEach({ (id) in
            id.backgroundColor = .clear
        })
        
        setupPageViewController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Buttons functions
    @IBAction func homeBtnClicked(_ sender: Any) {
        
        if doubleTapValue {
            storyVC.scrollToTop()
        }
        setSelectedForBtn(location: 0)
        changeViewTo(indexView: 0)
        
    }
    
    @IBAction func searchUserBtnClicked(_ sender: Any) {
        
        changeViewTo(indexView: 1)
        setSelectedForBtn(location: 1)
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
    
    
    @IBAction func notifBtnACtion(_ sender: Any) {
        setSelectedForBtn(location: 3)
        
    }
    
    @IBAction func userProfileClicked(_ sender: Any) {
        userProfileVC.user_account = userStatus.user_account
        setSelectedForBtn(location: 4)
        changeViewTo(indexView: 3)
    }
    
    private func setupPageViewController() {
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = nil
        self.pageViewController.view.frame = .zero
        
        changeViewTo(indexView: 0)
        setSelectedForBtn(location: 0)
        
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

    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    // MARK: - set up view for btn option
    private func changeViewTo(indexView:Int){
        pageViewController.setViewControllers([getPageFor(index: indexView)!],
                                              direction: currentViewIndex > indexView ? .reverse : .forward,
                                              animated: true,
                                              completion: nil)
        currentViewIndex = indexView
    }
    
    private func setSelectedForBtn(location:Int){
        indicator?[location].backgroundColor = UIColor.black
        btnOptions?[location].setImage(UIImage(systemName: "\(self.iconName[location]).fill"),
                                      for: .normal)
        for index in 0...4 {
            if index != location {
                btnOptions?[index].setImage(UIImage(systemName: "\(self.iconName[index])"),
                                            for: .normal)
                indicator?[index].backgroundColor = UIColor.clear
            }
        }
    }
    
    // Return page at index.
    private func getPageFor(index: Int) -> UIViewController? {
        return pagesVC[index]
    }
}
