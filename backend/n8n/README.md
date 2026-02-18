# n8n Workflows

인스타그램 인플루언서 공동구매 데이터 수집 자동화 워크플로우.

## Workflows

### Workflow B: Process Suggestions

> `workflows/workflow-b-process-suggestions.json`

사용자가 제보한 인스타그램 계정을 처리하여 인플루언서 프로필과 공구 게시글을 DB에 저장한다.

**흐름:**
[Todo: 워크플로우 스크린샷 첨부]

**노드 설명:**

| 노드 | 타입 | 설명 |
|------|------|------|
| Manual Trigger | Trigger | 수동 실행 |
| Supabase - Get Suggestions | Supabase | `influencer_suggestions` 테이블에서 제보된 username 전체 조회 |
| Loop Over Items | Split In Batches | 1명씩 순차 처리 (Apify rate limit 고려) |
| HTTP Request - Apify | HTTP Request | Apify Instagram Profile Scraper API 호출. 프로필 + 최신 12개 게시글 반환 |
| Profile Mapper | Code | Apify 응답을 `influencers` 테이블 컬럼에 매핑. 프로필이 없으면 `_skip` 반환 |
| Postgres - Influencers Upsert | Postgres | `influencers` 테이블에 INSERT ON CONFLICT UPDATE |
| Post Processor | Code | 공구 판별. Profile Mapper 출력을 직접 참조 (`$('Profile Mapper')`). `caption_raw` 포함 출력 |
| IF - Has Posts | IF | `_skip is true` 조건. 공구 게시글 없으면 Loop로, 있으면 Claude API 흐름으로 |
| Prepare Claude Request | Code | 각 게시글의 caption을 Claude API 요청 body로 변환 |
| Claude API - Extract Info | HTTP Request | Anthropic Messages API 호출 (Haiku 4.5). 캡션에서 기간/상품명/URL 추출 |
| Merge Claude Response | Code | Claude 응답 파싱 후 원본 게시글 데이터와 병합 |
| Postgres - Posts Upsert | Postgres | `posts` 테이블에 INSERT ON CONFLICT UPDATE (product_name, group_buying_url 포함) |
| Postgres - Truncate Suggestions | Postgres | 모든 처리 완료 후 `influencer_suggestions` 테이블 비우기 |

---

## 공구 판별 로직

Post Processor 노드에서 각 게시글의 caption + hashtags를 분석하여 공동구매 여부를 판별한다.

### Step 1: 강한 키워드 매칭

caption과 hashtags를 합친 텍스트에서 아래 키워드가 **1개라도** 포함되면 공구로 판정.

```
공구, 공동구매, 공구오픈, 공구마감, 공구기간, 공구가, 공구링크
```

### Step 2: 조합 키워드 매칭

Step 1에서 매칭되지 않은 경우, 아래 키워드가 **2개 이상** 포함되면 공구로 판정.

```
오픈, open, 마감, 구매, 링크, 프로필, 배송, 선착순, 한정, 할인, 혜택, 이벤트
```

### Step 3: Claude API 추출 (기존 regex 파싱 대체)

공구로 판정된 게시글의 caption을 Claude API (Haiku 4.5)에 전달하여 아래 4가지 정보를 추출한다.

| 추출 항목 | 설명 | 비고 |
|-----------|------|------|
| `group_buying_start` | 공구 시작 날짜 (ISO 8601) | nullable |
| `group_buying_end` | 공구 종료 날짜 (ISO 8601) | nullable |
| `product_name` | 공동구매 상품명 | nullable |
| `group_buying_url` | 공동구매 링크 URL | nullable |

모든 항목은 nullable이며, 캡션에 해당 정보가 없으면 null로 반환된다.

---

## Credentials

워크플로우 import 후 아래 Credential을 각 노드에 수동 연결해야 한다.

| Credential | 사용 노드 |
|-----------|----------|
| Supabase API | Supabase - Get Suggestions |
| Postgres (Supabase) | Influencers Upsert, Posts Upsert, Truncate Suggestions |
| Apify Token | HTTP Request - Apify (Query Param으로 직접 입력) |
| Anthropic API Key | Claude API - Extract Info (Header `x-api-key`로 직접 입력) |
