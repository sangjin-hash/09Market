//
//  HomePostCardCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import Domain
import Shared_DI
import Shared_ReactiveX

final class HomePostCardCell: UICollectionViewCell, ConfiguratorModule {

    struct Dependency {}

    struct Payload {
        let post: Post
    }

    var disposeBag = DisposeBag()

    var likeButton: UIButton { return self.postCardView.likeButton }


    // MARK: - UI

    private let postCardView = PostCardView()


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.postCardView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Configure

extension HomePostCardCell {
    func configure(dependency: Dependency, payload: Payload) {
        self.postCardView.configure(post: payload.post)
    }
}


// MARK: - Layout

extension HomePostCardCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.postCardView.pin.horizontally().top()
        self.postCardView.flex.layout(mode: .adjustHeight)
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        self.postCardView.pin.width(layoutAttributes.size.width)
        self.postCardView.flex.layout(mode: .adjustHeight)
        layoutAttributes.size = CGSize(
            width: layoutAttributes.size.width,
            height: self.postCardView.frame.height
        )
        return layoutAttributes
    }
}


// MARK: - Reuse

extension HomePostCardCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.postCardView.reset()
    }
}
