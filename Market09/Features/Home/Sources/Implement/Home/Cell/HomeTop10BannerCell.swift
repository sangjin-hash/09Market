//
//  HomeTop10BannerCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import Shared_DI
import Shared_UI

final class HomeTop10BannerCell: UICollectionViewCell, ConfiguratorModule {

    struct Dependency {}
    struct Payload {}


    // MARK: - UI

    private let bannerButton = UIButton(type: .system).then {
        // TODO: 추후에 이미지 버튼으로 변경할 것
        $0.setTitle("이번 주 핫딜 TOP 10", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Configure

extension HomeTop10BannerCell {
    func configure(dependency: Dependency, payload: Payload) {}
}


// MARK: - Layout

extension HomeTop10BannerCell {
    private func setupLayout() {
        self.contentView.addSubview(self.bannerButton)
        self.bannerButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


// MARK: - Reuse

extension HomeTop10BannerCell {
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
