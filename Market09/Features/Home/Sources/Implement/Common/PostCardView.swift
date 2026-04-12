//
//  PostCardView.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import DesignSystem
import Domain
import Shared_ReactiveX
import Shared_UI
import Util

import Kingfisher

final class PostCardView: UIView {

    private var disposeBag = DisposeBag()

    // MARK: - UI

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
        $0.setTitle(Strings.Home.goToLink, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 25
    }

    let likeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "heart"), for: .normal)
        $0.tintColor = .systemGray3
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 25
    }


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.06
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Configure

extension PostCardView {
    func configure(post: Post) {
        self.profileImageView.kf.indicatorType = .activity
        if let url = URL(string: post.influencer.profilePicUrl) {
            self.profileImageView.kf.setImage(
                with: url,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 40, height: 40))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ]
            )
        }
        self.nameLabel.text = post.influencer.fullName
        self.usernameLabel.text = "@\(post.influencer.username)"

        let status = post.groupBuyingStatus
        self.statusBadgeLabel.text = self.statusText(status)
        self.statusBadgeLabel.backgroundColor = self.statusColor(status)

        let hasImage = post.displayUrl != nil
        self.productImageView.flex.display(hasImage ? .flex : .none)
        self.productImageView.kf.indicatorType = .activity
        if let urlString = post.displayUrl,
           let url = URL(string: urlString) {
            let productSize = self.productImageView.bounds.size.width > 0
                ? self.productImageView.bounds.size
                : CGSize(
                    width: UIScreen.main.bounds.width - 32,
                    height: (UIScreen.main.bounds.width - 32) * 3 / 4
                )
            self.productImageView.kf.setImage(
                with: url,
                options: [
                    .processor(DownsamplingImageProcessor(size: productSize)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ]
            )
        }

        self.productNameLabel.text = post.productName

        let startStr = Formatters.displayDate.string(from: post.groupBuyingStart)
        let endStr = Formatters.displayDate.string(from: post.groupBuyingEnd)
        self.dateLabel.text = "\(startStr) ~ \(endStr)"

        if let price = post.price,
           let formatted = Formatters.decimalNumber.string(from: NSNumber(value: price)) {
            self.priceLabel.text = Strings.Home.price(formatted)
        } else {
            self.priceLabel.text = Strings.Home.priceUndecided
        }

        self.likesLabel.text = Strings.Home.likesCount(post.likesCount)

        let heartImage = post.isLiked ? "heart.fill" : "heart"
        self.likeButton.setImage(UIImage(systemName: heartImage), for: .normal)
        self.likeButton.tintColor = post.isLiked ? .systemPink : .systemGray3

        self.linkButton.rx.tap
            .subscribe(onNext: {
                guard let url = post.influencer.instagramProfileURL else { return }
                UIApplication.shared.open(url)
            })
            .disposed(by: self.disposeBag)

        self.flex.markDirty()
        self.setNeedsLayout()
    }

    func reset() {
        self.disposeBag = DisposeBag()
        self.profileImageView.kf.cancelDownloadTask()
        self.profileImageView.image = nil
        self.productImageView.kf.cancelDownloadTask()
        self.productImageView.image = nil
        self.productImageView.flex.display(.flex)
    }

    private func statusText(_ status: GroupBuyingStatus) -> String {
        switch status {
        case .upcoming: return Strings.Home.statusUpcoming
        case .ongoing: return Strings.Home.statusOngoing
        case .closingSoon: return Strings.Home.statusClosingSoon
        case .closed: return Strings.Home.statusClosed
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

extension PostCardView {
    private func setupLayout() {
        self.flex.direction(.column).padding(16).define { flex in
            flex.addItem().direction(.row).alignItems(.center).define { row in
                row.addItem(self.profileImageView).size(40)
                row.addItem().direction(.column).marginLeft(10).shrink(1).define { col in
                    col.addItem(self.nameLabel)
                    col.addItem(self.usernameLabel)
                }
            }

            flex.addItem(self.statusBadgeLabel)
                .alignSelf(.start)
                .marginTop(12)
                .height(24)
                .paddingHorizontal(10)

            flex.addItem(self.productImageView)
                .marginTop(12)
                .aspectRatio(4.0 / 3.0)

            flex.addItem(self.productNameLabel).marginTop(12)

            flex.addItem().direction(.row).alignItems(.center).marginTop(6).define { row in
                row.addItem(self.calendarIconView).size(16)
                row.addItem(self.dateLabel).marginLeft(4)
            }

            flex.addItem(self.priceLabel).marginTop(8)

            flex.addItem().direction(.row).alignItems(.center).marginTop(8).define { row in
                row.addItem(self.heartIconView).size(16)
                row.addItem(self.likesLabel).marginLeft(4)
            }

            flex.addItem().direction(.row).alignItems(.center).marginTop(16).define { row in
                row.addItem(self.linkButton).grow(1).height(50)
                row.addItem(self.likeButton).size(50).marginLeft(10)
            }
        }
    }
}
