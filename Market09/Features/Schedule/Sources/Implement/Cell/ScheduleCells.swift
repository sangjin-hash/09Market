//
//  ScheduleCells.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

import SnapKit
import Shared_ReactiveX

// MARK: - Title Cell
final class ScheduleTitleCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "공구일정"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Filter Cell
final class ScheduleFilterCell: UICollectionViewCell {
    let allButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("전체 공구", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.backgroundColor = UIColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0)
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    let followButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("팔로우한 인플루언서", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [allButton, followButton])
        stack.axis = .horizontal
        stack.spacing = 10
        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        allButton.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(90)
        }
        followButton.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(150)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Calendar Date Cell
final class ScheduleCalendarDateCell: UICollectionViewCell {
    let circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.backgroundColor = UIColor.systemGray6
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(circleView)
        circleView.addSubview(dateLabel)
        
        circleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(date: Date, isSelected: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)
        
        if isSelected {
            circleView.backgroundColor = UIColor(red: 0.98, green: 0.45, blue: 0.12, alpha: 1.0)
            dateLabel.textColor = .white
        } else {
            circleView.backgroundColor = UIColor.systemGray6
            dateLabel.textColor = .black
        }
    }
}

// MARK: - Category Cell
final class ScheduleCategoryCell: UICollectionViewCell {
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .gray
        return iv
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(icon: String, name: String, isSelected: Bool) {
        titleLabel.text = name
        iconImageView.image = UIImage(systemName: icon)
        
        if isSelected {
            containerView.backgroundColor = UIColor(red: 0.98, green: 0.45, blue: 0.12, alpha: 1.0)
            containerView.layer.borderColor = UIColor(red: 0.98, green: 0.45, blue: 0.12, alpha: 1.0).cgColor
            titleLabel.textColor = .white
            iconImageView.tintColor = .white
        } else {
            containerView.backgroundColor = .white
            containerView.layer.borderColor = UIColor.systemGray5.cgColor
            titleLabel.textColor = .darkGray
            iconImageView.tintColor = .gray
        }
    }
}

// MARK: - Schedule List Cell
final class ScheduleCardCell: UICollectionViewCell {
    let colorBarView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()
    
    let cardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray6.cgColor
        return v
    }()
    
    let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()
    
    let influencerIcon: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray4
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()
    
    let influencerLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .gray
        return l
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .black
        l.numberOfLines = 2
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorBarView)
        contentView.addSubview(cardContainer)
        
        cardContainer.addSubview(thumbImageView)
        cardContainer.addSubview(influencerIcon)
        cardContainer.addSubview(influencerLabel)
        cardContainer.addSubview(titleLabel)
        
        colorBarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        cardContainer.snp.makeConstraints { make in
            make.leading.equalTo(colorBarView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
        }
        thumbImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }
        influencerIcon.snp.makeConstraints { make in
            make.top.equalTo(thumbImageView)
            make.leading.equalTo(thumbImageView.snp.trailing).offset(12)
            make.width.height.equalTo(16)
        }
        influencerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(influencerIcon)
            make.leading.equalTo(influencerIcon.snp.trailing).offset(6)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(influencerIcon.snp.bottom).offset(6)
            make.leading.equalTo(thumbImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, influencer: String, color: UIColor) {
        titleLabel.text = title
        influencerLabel.text = influencer
        colorBarView.backgroundColor = color
    }
}
