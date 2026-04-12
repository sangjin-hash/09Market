//
//  HomeTop10BannerCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import DesignSystem
import Shared_DI
import Shared_UI

final class HomeTop10BannerCell: UICollectionViewCell, ConfiguratorModule {

    struct Dependency {}
    struct Payload {}


    // MARK: - UI

    private let bannerButton = UIImageView().then {
        $0.image = UIImage(named: "top10_banner")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
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
