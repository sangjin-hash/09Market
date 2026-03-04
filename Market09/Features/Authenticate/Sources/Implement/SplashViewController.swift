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
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
