//
//  Strings.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

public enum Strings {
    public enum Common {
        public static let confirm = "확인"
        public static let cancel = "취소"
        public static let retry = "재시도"
    }

    public enum Tab {
        public static let home = "홈"
        public static let temp = "임시"
        public static let profile = "프로필"
    }

    public enum Home {
        public static let searchPlaceholder = "브랜드, 상품 검색"
        public static let loginRequired = "로그인이 필요합니다.\n로그인 화면으로 이동할까요?"
        public static let goToLink = "공구 링크로 이동"
        public static let priceUndecided = "가격 미정"
        public static let categoryAll = "전체"
        public static let top10Banner = "이번 주 핫딜 TOP 10"
        public static let statusUpcoming = "오픈예정"
        public static let statusOngoing = "진행중"
        public static let statusClosingSoon = "마감임박"
        public static let statusClosed = "마감"

        public static func likesCount(_ count: Int) -> String {
            return "\(count)명이 좋아합니다"
        }

        public static func price(_ formatted: String) -> String {
            return "\(formatted)원"
        }
    }

    public enum Profile {
        public static let login = "로그인하기"
        public static let logout = "로그아웃"
        public static let deleteAccount = "회원탈퇴"
        public static let logoutConfirm = "로그아웃 하시겠어요?"
        public static let defaultNickname = "사용자"
    }

    public enum Auth {
        public static let googleLogin = "구글 로그인"
        public static let appleLogin = "애플 로그인"
        public static let splash = "스플래시"
    }
    
    public enum CreatePost {
        public static let title = "공구 등록하기"
        public static let sectionInfluencer = "인플루언서 검색"
        public static let influencerPlaceholder = "알파벳이나 이름을 입력하세요"
        public static let sectionProductImage = "상품 이미지"
        public static let imageAddButton = "공구 이미지 추가"
        public static let sectionProductName = "상품명"
        public static let productNamePlaceholder = "공구 상품명을 입력하세요"
        public static let sectionPrice = "가격"
        public static let priceSuffix = "원"
        public static let sectionCategory = "카테고리"
        public static let categoryPlaceholder = "카테고리를 선택하세요"
        public static let sectionStartDate = "시작일"
        public static let sectionEndDate = "마감일"
        public static let datePlaceholder = "연도. 월. 일."
        public static let submitButton = "공구 등록하기"
        public static let imageFileSizeError = "10MB 이내 파일만 선택 가능합니다"
    }

    public enum RegisterInfluencer {
        public static let title = "인플루언서 등록하기"
        public static let usernamePlaceholder = "인스타그램 username을 입력하세요"
        public static let submitButton = "등록 요청"
        public static let successMessage = "추가해주신 인플루언서는 심사 이후 공구 게시글들이 추가될 예정입니다."
        public static let duplicateMessage = "이미 등록된 인플루언서입니다"
    }
}
