//
//  ScheduleHeaders.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

import SnapKit
import Shared_ReactiveX

final class ScheduleCalendarHeaderView: UICollectionReusableView {
    var disposeBag = DisposeBag()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        label.textColor = UIColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0)
        return label
    }()
    
    let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        let days = ["월", "화", "수", "목", "금", "토", "일"]
        for day in days {
            let l = UILabel()
            l.text = day
            l.textColor = .systemGray
            l.font = .systemFont(ofSize: 13, weight: .semibold)
            l.textAlignment = .center
            stack.addArrangedSubview(l)
        }
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(weekdayStackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
        leftButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(rightButton.snp.leading).offset(-10)
            make.width.height.equalTo(30)
        }
        weekdayStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

final class ScheduleListHeaderView: UICollectionReusableView {
    let topDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        return v
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "오늘의 일정"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = .systemGray
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topDivider)
        addSubview(titleLabel)
        
        topDivider.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(topDivider.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
