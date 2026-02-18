# n8n Workflows

인스타그램 인플루언서 공동구매 데이터 수집 자동화 워크플로우.

## Workflows

### Process Suggestions

> `workflows/process-suggestions.json`

`influencer_suggestions` 테이블에 제보된 인플루언서를 처리하는 워크플로우.

```
Manual Trigger → Get Suggestions → Loop → Apify → Profile Mapper → Influencers Upsert
  → Get Existing Post IDs → Post Processor → IF → Claude API → Posts Upsert → Loop
  → (Loop 완료) → Truncate Suggestions
```

**노드 설명:**

| 노드 | 타입 | 설명 |
|------|------|------|
| Manual Trigger | Trigger | 수동 실행 |
| Supabase - Get Suggestions | Supabase | `influencer_suggestions` 테이블에서 제보된 username 전체 조회 |
| Loop Over Items | Split In Batches | 1명씩 순차 처리 (Apify rate limit 고려) |
| HTTP Request - Apify | HTTP Request | Apify Instagram Profile Scraper API 호출. 프로필 + 최신 12개 게시글 반환 |
| Profile Mapper | Code | Apify 응답을 `influencers` 테이블 컬럼에 매핑. 프로필이 없으면 `_skip` 반환 |
| Postgres - Influencers Upsert | Postgres | `influencers` 테이블에 INSERT ON CONFLICT UPDATE |
| Postgres - Get Existing Post IDs | Postgres | 해당 인플루언서의 기존 게시글 ID 목록 조회 (중복 처리 방지) |
| Post Processor | Code | 기존 게시글 필터링 + 공구 판별. 새 게시글만 통과 |
| IF - Has Posts | IF | `_skip is true` 조건. 공구 게시글 없으면 Loop로, 있으면 Claude API 흐름으로 |
| Prepare Claude Request | Code | 각 게시글의 caption을 Claude API 요청 body로 변환. 프로필 링크 참조 감지 포함 |
| Claude API - Extract Info | HTTP Request | Anthropic Messages API 호출 (Haiku 4.5). 캡션에서 기간/상품명/URL 추출 |
| Merge Claude Response | Code | Claude 응답 파싱 후 원본 데이터와 병합. start 미명시 시 posted_at 대체, PROFILE_LINK → external_url 대체 |
| Postgres - Posts Upsert | Postgres | `posts` 테이블에 INSERT ON CONFLICT UPDATE |
| Postgres - Truncate Suggestions | Postgres | 모든 처리 완료 후 `influencer_suggestions` 테이블 비우기 |

---

### Sync All Influencers

> `workflows/sync-all-influencers.json`

`influencers` 테이블의 모든 인플루언서 프로필을 업데이트하고 새 게시글만 수집하는 워크플로우.
기존에 DB에 있는 게시글(post ID 기준)은 스킵하여 불필요한 Claude API 호출을 방지한다.

```
Manual Trigger → Get All Influencers → Loop → Apify → Profile Mapper → Influencers Upsert
  → Get Existing Post IDs → Post Processor → IF → Claude API → Posts Upsert → Loop
```

Workflow B와 처리 파이프라인(Apify → 프로필 업데이트 → 공구 판별 → Claude API → DB 저장)은 동일하다.
차이점은 데이터 소스(`influencers` 테이블)와 Truncate Suggestions가 없다는 점.

**노드 설명:**

| 노드 | 타입 | 설명 |
|------|------|------|
| Manual Trigger | Trigger | 수동 실행 |
| Postgres - Get All Influencers | Postgres | `influencers` 테이블에서 전체 username 조회 |
| 이하 동일 | - | Workflow B와 동일한 파이프라인 |

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

### Step 3: Claude API 추출

공구로 판정된 게시글의 caption을 Claude API (Haiku 4.5)에 전달하여 아래 4가지 정보를 추출한다.

| 추출 항목 | 설명 | 비고 |
|-----------|------|------|
| `group_buying_start` | 공구 시작 날짜 (ISO 8601) | 미명시 시 `posted_at` 사용 |
| `group_buying_end` | 공구 종료 날짜 (ISO 8601) | nullable |
| `product_name` | 공동구매 상품명 | nullable |
| `group_buying_url` | 공동구매 링크 URL | "프로필 링크" 참조 시 인플루언서 `external_url` 사용 |

**Fallback 로직:**
- `group_buying_start`가 null → 게시글 작성시간(`posted_at`)으로 대체
- 캡션에 "프로필 링크 확인", "링크는 프로필" 등 프로필 링크 참조 문구 → 인플루언서의 `external_url`로 대체

---

## Credentials

워크플로우 import 후 아래 Credential을 각 노드에 수동 연결해야 한다.

| Credential | 사용 노드 | 해당 워크플로우 |
|-----------|----------|----------------|
| Supabase API | Supabase - Get Suggestions | B |
| Postgres (Supabase) | Influencers Upsert, Posts Upsert, Get Existing Post IDs, Truncate Suggestions | B |
| Postgres (Supabase) | Influencers Upsert, Posts Upsert, Get All Influencers, Get Existing Post IDs | C |
| Apify Token | HTTP Request - Apify | B, C |
| Anthropic API Key | Claude API - Extract Info (Generic Credential Type → Header Auth, Name: `x-api-key`) | B, C |
