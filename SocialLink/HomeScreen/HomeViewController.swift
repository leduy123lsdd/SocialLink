//
//  HomeViewController.swift
//  SocialLink
//
//  Created by Lê Duy on 3/13/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var scrollContainer: UIView!
    
    
    
    
    
    let storyVC = StoryVC(nibName: "StoryVC", bundle: nil)
    let searchUserVC = SearchUserVC(nibName: "SearchUserVC", bundle: nil)
    let createPostVC = CreatePostVC(nibName: "CreatePostVC", bundle: nil)
    let userProfileVC = UserProfileVC(nibName: "UserProfileVC", bundle: nil)
    
    var pagesVC = [UIViewController]()
    
    // MARK: Buttons functions
    
    @IBAction func homeBtnClicked(_ sender: Any) {
        setViewController(index: 0)
    }
    
    @IBAction func searchUserBtnClicked(_ sender: Any) {
        setViewController(index: 1)
        self.view.bringSubviewToFront(pagesVC[1].view)
    }
    
    @IBAction func createPostClicked(_ sender: Any) {
        setViewController(index: 2)
    }
    
    @IBAction func userProfileClicked(_ sender: Any) {
        setViewController(index: 3)
    }
    
    lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pagesVC = [storyVC,searchUserVC,createPostVC,userProfileVC]
        setupPageViewController()
    }
    
    func setupPageViewController() {
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
