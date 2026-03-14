//
//  HomePostCardCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import Domain
import Shared_DI
import Shared_UI

import Kingfisher

final class HomePostCardCell: UICollectionViewCell, ConfiguratorModule {

    struct Dependency {}

    struct Payload {
        let post: Post
    }


    // MARK: - Formatter

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()


    // MARK: - UI

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.06
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
    }

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .systemGray5
    }

    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
    }

    private let usernameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .systemGray
    }
    
    private let statusBadgeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }

    private let productImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray5
    }

    private let productNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 2
    }

    private let calendarIconView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = .systemGray
        $0.contentMode = .scaleAspectFit
    }

    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .systemGray
    }

    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
    }

    private let heartIconView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.tintColor = .systemPink
        $0.contentMode = .scaleAspectFit
    }

    private let likesLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .systemGray
    }

    private let linkButton = UIButton(type: .system).then {
        $0.setTitle("공구 링크로 이동", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 25
    }

    private let favoriteButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "heart"), for: .normal)
        $0.tintColor = .systemGray3
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 25
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

extension HomePostCardCell {
    func configure(dependency: Dependency, payload: Payload) {
        let post = payload.post

        // Profile
        if let url = URL(string: post.influencer.profilePicUrl) {
            self.profileImageView.kf.setImage(with: url)
        }
        self.nameLabel.text = post.influencer.fullName
        self.usernameLabel.text = "@\(post.influencer.username)"

        // Status badge
        let status = post.groupBuyingStatus
        self.statusBadgeLabel.text = self.statusText(status)
        self.statusBadgeLabel.backgroundColor = self.statusColor(status)

        // Product image
        let hasImage = !(post.imageUrls ?? []).isEmpty
        self.productImageView.flex.display(hasImage ? .flex : .none)
        if hasImage,
           let urlString = post.imageUrls?.first,
           let url = URL(string: urlString) {
            self.productImageView.kf.setImage(with: url)
        }

        // Product info
        self.productNameLabel.text = post.productName

        let startStr = Self.dateFormatter.string(from: post.groupBuyingStart)
        let endStr = Self.dateFormatter.string(from: post.groupBuyingEnd)
        self.dateLabel.text = "\(startStr) ~ \(endStr)"

        if let price = post.price,
           let formatted = Self.priceFormatter.string(from: NSNumber(value: price)) {
            self.priceLabel.text = "\(formatted)원"
        } else {
            self.priceLabel.text = "가격 미정"
        }

        // Likes
        self.likesLabel.text = "\(post.likesCount)명이 좋아합니다"

        // Favorite
        let heartImage = post.isLiked ? "heart.fill" : "heart"
        self.favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        self.favoriteButton.tintColor = post.isLiked ? .systemPink : .systemGray3

        self.containerView.flex.markDirty()
        self.setNeedsLayout()
    }

    private func statusText(_ status: GroupBuyingStatus) -> String {
        switch status {
        case .upcoming: return "오픈예정"
        case .ongoing: return "진행중"
        case .closingSoon: return "마감임박"
        case .closed: return "마감"
        }
    }

    private func statusColor(_ status: GroupBuyingStatus) -> UIColor {
        switch status {
        case .upcoming: return .systemBlue
        case .ongoing: return .systemGreen
        case .closingSoon: return .systemOrange
        case .closed: return .systemGray
        }
    }
}


// MARK: - Layout

extension HomePostCardCell {
    private func setupLayout() {
        self.contentView.addSubview(self.containerView)

        self.containerView.flex.direction(.column).padding(16).define { flex in
            // Profile row
            flex.addItem().direction(.row).alignItems(.center).define { row in
                row.addItem(self.profileImageView).size(40)
                row.addItem().direction(.column).marginLeft(10).shrink(1).define { col in
                    col.addItem(self.nameLabel)
                    col.addItem(self.usernameLabel)
                }
            }

            // Status badge
            flex.addItem(self.statusBadgeLabel)
                .alignSelf(.start)
                .marginTop(12)
                .height(24)
                .paddingHorizontal(10)

            // Product image (hide/show via display)
            flex.addItem(self.productImageView)
                .marginTop(12)
                .aspectRatio(4.0 / 3.0)

            // Product name
            flex.addItem(self.productNameLabel).marginTop(12)

            // Date row
            flex.addItem().direction(.row).alignItems(.center).marginTop(6).define { row in
                row.addItem(self.calendarIconView).size(16)
                row.addItem(self.dateLabel).marginLeft(4)
            }

            // Price
            flex.addItem(self.priceLabel).marginTop(8)

            // Likes row
            flex.addItem().direction(.row).alignItems(.center).marginTop(8).define { row in
                row.addItem(self.heartIconView).size(16)
                row.addItem(self.likesLabel).marginLeft(4)
            }

            // Button row
            flex.addItem().direction(.row).alignItems(.center).marginTop(16).define { row in
                row.addItem(self.linkButton).grow(1).height(50)
                row.addItem(self.favoriteButton).size(50).marginLeft(10)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.pin.horizontally().top()
        self.containerView.flex.layout(mode: .adjustHeight)
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        self.containerView.pin.width(layoutAttributes.size.width)
        self.containerView.flex.layout(mode: .adjustHeight)
        layoutAttributes.size = CGSize(
            width: layoutAttributes.size.width,
            height: self.containerView.frame.height
        )
        return layoutAttributes
    }
}


// MARK: - Reuse

extension HomePostCardCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.kf.cancelDownloadTask()
        self.profileImageView.image = nil
        self.productImageView.kf.cancelDownloadTask()
        self.productImageView.image = nil
        self.productImageView.flex.display(.flex)
    }
}
