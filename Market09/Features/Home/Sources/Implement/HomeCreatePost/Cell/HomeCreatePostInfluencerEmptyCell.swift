//
//  HomeCreatePostInfluencerEmptyCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import DesignSystem
import Shared_UI

final class HomeCreatePostInfluencerEmptyCell: UICollectionViewCell {


    // MARK: - UI

    private let emptyLabel = UILabel().then {
        $0.text = Strings.CreatePost.influencerSearchEmpty
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
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


// MARK: - Layout

extension HomeCreatePostInfluencerEmptyCell {
    private func setupLayout() {
        self.contentView.backgroundColor = .systemBackground

        self.contentView.flex
            .alignItems(.center)
            .justifyContent(.center)
            .define { flex in
                flex.addItem(self.emptyLabel)
            }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.flex.layout()
    }
}
