//
//  ErrorString.swift
//  AppCore
//
//  Created by Sangjin Lee
//

public enum ErrorString {
    public enum Network {
        public static let notConnected    = "네트워크 연결을 확인해주세요."
        public static let timeout         = "요청 시간이 초과되었습니다. 다시 시도해주세요."
        public static let notFound        = "요청한 정보를 찾을 수 없습니다."
        public static let serverError     = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        public static let invalidResponse = "응답을 처리할 수 없습니다."
        public static let connectionLost  = "연결이 끊겼습니다. 다시 시도해주세요."
        public static let sslError        = "보안 연결에 실패했습니다."
        public static let rateLimited     = "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
    }

    public enum Auth {
        public static let sessionExpired     = "세션이 만료되었습니다. 다시 로그인해주세요."
        public static let invalidCredentials = "인증 정보가 올바르지 않습니다."
        public static let providerFailed     = "인증 처리 중 오류가 발생했습니다."
        public static let rateLimited        = "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
    }

    public enum Client {
        public static let imageSizeLimitExceeded   = "10MB 이하 사진을 선택해주세요."
        public static let photoLibraryAccessDenied = "앨범 접근 권한이 필요합니다. 설정에서 허용해주세요."
        public static let invalidImageFormat        = "지원하지 않는 이미지 형식입니다."
    }

    public enum Storage {
        public static let insufficientSpace = "기기 저장 공간이 부족합니다. 저장 공간을 확보한 후 다시 시도해주세요."
    }

    public enum Server {
        public static let influencerConflict = "이미 등록된 인플루언서입니다."
        public static let unknown            = "이미 처리된 요청입니다."
    }
}
