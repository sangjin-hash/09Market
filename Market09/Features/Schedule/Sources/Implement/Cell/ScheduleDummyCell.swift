//
//  ScheduleDummyCell.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

final class ScheduleDummyCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, color: UIColor) {
        label.text = text
        contentView.backgroundColor = color
    }
}
