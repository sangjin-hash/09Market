//
//  SplashViewController.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import UIKit

final class SplashViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "스플래시"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
