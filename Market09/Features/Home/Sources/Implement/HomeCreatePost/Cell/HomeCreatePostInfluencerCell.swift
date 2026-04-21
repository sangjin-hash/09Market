//
//  HomeCreatePostInfluencerCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import Domain
import Kingfisher
import Shared_DI
import Shared_UI

final class HomeCreatePostInfluencerCell: UICollectionViewCell, ConfiguratorModule {

    struct Dependency {}

    struct Payload {
        let influencer: Influencer
    }

    // MARK: - UI

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .systemGray5
    }

    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .label
        $0.numberOfLines = 1
    }


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Highlight

    override var isHighlighted: Bool {
        didSet {
            self.contentView.backgroundColor = self.isHighlighted
                ? UIColor.systemBlue.withAlphaComponent(0.12)
                : .systemBackground
        }
    }
}


// MARK: - Configure

extension HomeCreatePostInfluencerCell {
    func configure(dependency: Dependency, payload: Payload) {
        self.profileImageView.kf.setImage(
            with: URL(string: payload.influencer.profilePicUrl),
            placeholder: UIImage(systemName: "person.circle.fill")
        )
        self.nameLabel.text = "@\(payload.influencer.username) \(payload.influencer.fullName)"
        self.contentView.flex.layout()
    }
}


// MARK: - Layout

extension HomeCreatePostInfluencerCell {
    private func setupLayout() {
        self.contentView.backgroundColor = .systemBackground

        self.contentView.flex
            .direction(.row)
            .alignItems(.center)
            .paddingHorizontal(16)
            .define { flex in
                flex.addItem(self.profileImageView).size(32).marginRight(10)
                flex.addItem(self.nameLabel).grow(1).shrink(1)
            }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.flex.layout()
    }
}


// MARK: - Reuse

extension HomeCreatePostInfluencerCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.kf.cancelDownloadTask()
        self.profileImageView.image = nil
        self.contentView.backgroundColor = .systemBackground
    }
}
