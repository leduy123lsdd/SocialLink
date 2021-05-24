//
//  ChatingUIView.swift
//  SocialLink
//
//  Created by Lê Duy on 5/24/21.
//

import UIKit

class ChatingUIView: UIView {
    
    @IBOutlet var containerView: UIView!
    

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
        Bundle.main.loadNibNamed("ThoiGianView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
}
