//
//  Colors.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

import UIKit

public enum Colors {

    // MARK: - Brand

    public static let primary = UIColor(hex: "#FF6B35")
    public static let secondary = UIColor(hex: "#2EC4B6")
    

    // MARK: - Background

    public static let background = UIColor.systemBackground
    public static let secondaryBackground = UIColor.secondarySystemBackground
    

    // MARK: - Text

    public static let textPrimary = UIColor.label
    public static let textSecondary = UIColor.secondaryLabel
    

    // MARK: - Semantic

    public static let success = UIColor.systemGreen
    public static let warning = UIColor.systemYellow
    public static let error = UIColor.systemRed
}


// MARK: - UIColor + Hex

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1.0
        )
    }
}
