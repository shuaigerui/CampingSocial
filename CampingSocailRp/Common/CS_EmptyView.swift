//
//  CS_EmptyView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

class CS_EmptyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(emptyView)
        addSubview(emptyLabel)
        
        emptyView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(64)
        }
        emptyLabel.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(emptyView.snp.bottom).offset(17)
        }
    }
    
    private let emptyView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "common_emtpy")
        return v
    }()
    private let emptyLabel: UILabel = {
        let v = UILabel()
        v.text = "No data available"
        v.textColor = UIColor(hex: "#666666")
        v.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return v
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
