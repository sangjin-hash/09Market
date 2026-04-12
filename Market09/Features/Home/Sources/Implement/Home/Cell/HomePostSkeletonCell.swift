//
//  HomePostSkeletonCell.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Shared_UI

final class HomePostSkeletonCell: UICollectionViewCell {

    // MARK: - UI

    private let skeletonView = PostCardSkeletonView()


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.skeletonView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Layout

extension HomePostSkeletonCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.skeletonView.pin.horizontally().top()
        self.skeletonView.flex.layout(mode: .adjustHeight)
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        self.skeletonView.pin.width(layoutAttributes.size.width)
        self.skeletonView.flex.layout(mode: .adjustHeight)
        layoutAttributes.size = CGSize(
            width: layoutAttributes.size.width,
            height: self.skeletonView.frame.height
        )
        return layoutAttributes
    }
}


// MARK: - Reuse

extension HomePostSkeletonCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.skeletonView.stopShimmer()
    }
}
