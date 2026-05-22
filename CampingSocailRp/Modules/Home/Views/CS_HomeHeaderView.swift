//
//  CS_HomeHeaderView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_HomeHeaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(joinButton)
        addSubview(AIButton)
        addSubview(outdoorLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        joinButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        AIButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(joinButton.snp.bottom).offset(8)
        }
        outdoorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(AIButton.snp.bottom).offset(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    @objc private func onJoin(){
        
        
    }
    
    @objc private func onAI(){
        
        
    }
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        v.text = "APPNAME"
        return v
    }()
    
    private lazy var joinButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "home_top"), for: .normal)
        btn.addTarget(self, action: #selector(onJoin), for: .touchUpInside)
        return btn
    }()
    
    private lazy var AIButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "home_ai"), for: .normal)
        btn.addTarget(self, action: #selector(onAI), for: .touchUpInside)
        return btn
    }()
    
    private lazy var outdoorLabel: UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 15)
        v.text = "Outdoor Diaries "
        return v
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
