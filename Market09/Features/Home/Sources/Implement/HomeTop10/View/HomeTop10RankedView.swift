//
//  HomeTop10RankedView.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Domain
import Shared_UI

final class HomeTop10RankedView: UIView {

    struct Payload {
        let post: Post
        let rank: Int
    }


    // MARK: - UI

    private let rankBadgeView = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true
    }

    private let postCardView = PostCardView()


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.postCardView)
        self.addSubview(self.rankBadgeView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Configure

extension HomeTop10RankedView {
    func configure(payload: Payload) {
        self.rankBadgeView.text = "\(payload.rank)"
        self.postCardView.configure(post: payload.post)
    }
}


// MARK: - Layout

extension HomeTop10RankedView {
    override func layoutSubviews() {
        super.layoutSubviews()

        // 1. 너비 먼저 설정 (flex 계산용): badge(44) + 양쪽 패딩(15) + 간격(15) = 74
        self.postCardView.frame.size.width = self.bounds.width - 74 - 15
        // 2. flex로 높이 계산 (origin이 0,0으로 초기화됨)
        self.postCardView.flex.layout(mode: .adjustHeight)
        // 3. PinLayout으로 위치 재설정 (height는 step 2 값 유지, width/x/y만 재적용)
        self.postCardView.pin.left(74).right(15).top()

        self.rankBadgeView.pin.left(15).top(16).size(44)

        let totalHeight = self.postCardView.frame.maxY
        if self.frame.height != totalHeight {
            self.frame.size.height = totalHeight
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.postCardView.frame.maxY > 0
                ? self.postCardView.frame.maxY
                : UIView.noIntrinsicMetric
        )
    }
}
