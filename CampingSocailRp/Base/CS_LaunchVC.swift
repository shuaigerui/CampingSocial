//
//  CS_LaunchVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/27.
//

import UIKit

class CS_LaunchVC: UIViewController {

    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        // 隐藏导航栏（整个导航栏会消失）
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.completion?()
        }
    }
    
    private let bgView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = "launch_bg".toImage
        return v
    }()

}
