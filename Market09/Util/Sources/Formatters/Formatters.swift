//
//  Formatters.swift
//  Util
//
//  Created by Sangjin Lee
//

import Foundation

public enum Formatters {

    /// "M/d" 형식 날짜 포맷터 (예: 4/10)
    public static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    /// ISO8601 파싱용 포맷터 (밀리초 포함, 서버 응답 → Date 변환)
    public static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// ISO8601 요청용 포맷터 (밀리초 미포함, Date → 서버 요청 변환)
    public static let iso8601Request: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// 천 단위 구분 숫자 포맷터 (예: 12,000)
    public static let decimalNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
