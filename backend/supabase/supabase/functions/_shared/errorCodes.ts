/**
 * 서버-클라이언트 공유 에러 코드
 * 형태: Feature.reason
 * iOS의 ServerErrorCode.RawValue와 동일한 문자열 사용
 */
export const AppErrorCode = {

  // 400 Bad Request
  BAD_REQUEST: "bad_request",

  // 401 Unauthorized
  UNAUTHORIZED: "unauthorized",

  // 404 Not Found
  NOT_FOUND: "not_found",

  // 409 Conflict - Feature.reason 형태
  INFLUENCER_CONFLICT: "influencer.conflict",
  // 추후: POST_CONFLICT: "post.conflict",

  // 500 Internal Server Error
  INTERNAL_ERROR: "internal_error",

} as const;

export type AppErrorCode = typeof AppErrorCode[keyof typeof AppErrorCode];
