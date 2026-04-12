//
//  PostCardSkeletonView.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Shared_UI

final class PostCardSkeletonView: UIView {

    // MARK: - UI

    private let profileBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 20
    }

    private let nameBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 4
    }

    private let usernameBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 4
    }

    private let badgeBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 6
    }

    private let imageBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 8
    }

    private let titleBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 4
    }

    private let dateBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 4
    }

    private let priceBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 4
    }

    private let likesBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 4
    }

    private let buttonBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 25
    }

    private let favoriteBox = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 25
    }

    private lazy var shimmerBoxes: [UIView] = [
        self.profileBox, self.nameBox, self.usernameBox, self.badgeBox,
        self.imageBox, self.titleBox, self.dateBox, self.priceBox,
        self.likesBox, self.buttonBox, self.favoriteBox,
    ]


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Shimmer

extension PostCardSkeletonView {
    func startShimmer() {
        guard self.shimmerBoxes.first?.layer.animation(forKey: "shimmer") == nil else {
            return
        }

        for box in self.shimmerBoxes {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor.systemGray5.cgColor,
                UIColor.systemGray4.cgColor,
                UIColor.systemGray5.cgColor,
            ]
            gradient.locations = [0.0, 0.5, 1.0]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.frame = box.bounds
            gradient.cornerRadius = box.layer.cornerRadius
            box.layer.addSublayer(gradient)

            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.duration = 1.2
            animation.repeatCount = .infinity
            gradient.add(animation, forKey: "shimmer")
        }
    }

    func stopShimmer() {
        for box in self.shimmerBoxes {
            box.layer.sublayers?
                .filter { $0 is CAGradientLayer }
                .forEach { $0.removeFromSuperlayer() }
        }
    }
}


// MARK: - Layout

extension PostCardSkeletonView {
    private func setupLayout() {
        self.flex.direction(.column).padding(16).define { flex in
            flex.addItem().direction(.row).alignItems(.center).define { row in
                row.addItem(self.profileBox).size(40)
                row.addItem().direction(.column).marginLeft(10).define { col in
                    col.addItem(self.nameBox).width(80).height(14)
                    col.addItem(self.usernameBox).width(60).height(12).marginTop(4)
                }
            }

            flex.addItem(self.badgeBox)
                .width(60)
                .height(24)
                .marginTop(12)

            flex.addItem(self.imageBox)
                .marginTop(12)
                .aspectRatio(4.0 / 3.0)

            flex.addItem(self.titleBox)
                .width(70%)
                .height(16)
                .marginTop(12)

            flex.addItem(self.dateBox)
                .width(100)
                .height(14)
                .marginTop(6)

            flex.addItem(self.priceBox)
                .width(120)
                .height(22)
                .marginTop(8)

            flex.addItem(self.likesBox)
                .width(130)
                .height(14)
                .marginTop(8)

            flex.addItem().direction(.row).alignItems(.center).marginTop(16).define { row in
                row.addItem(self.buttonBox).grow(1).height(50)
                row.addItem(self.favoriteBox).size(50).marginLeft(10)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.flex.layout(mode: .adjustHeight)
        startShimmer()
    }
}
