# SEC-VC-01 근본 시정 설계 (design-r01)

> 작성: architect(쏠쏠 브랜드 세션) · 2026-07-02 (KST) · 성격: **설계·판정 정본 초안**(구현=한데관/조백개, 허브 중재 경유).
> blocker: `_ledger.md` SEC-VC-01(open). 시크릿·PII 값 미기재.

## 0. 근본원인
brand-api A5(`/email-code/issue`)가 `codeHash=sha256("email:code")`를 **HMAC 서명(암호화 아님) 티켓**(`issueToken`)으로 클라에 반환 → 디코드로 codeHash 노출 → 6자리(10^6)+email 기지 → **오프라인 완전탐색**으로 verifyToken 위조. 레이트리밋 무력(오프라인). **근본원인 = 서버측 원장 부재(stateless)** — 검증 기준이 서버가 아닌 클라 토큰에. A7/A8(pw_reset)도 동일 계열.

> **선례**: 학습자단(solsol-api)은 **tenant 스키마 `TB_AUTH_CODE`**(+`TB_PASSWORD_RESET_TOKEN`, `TB_MEMBER` 대상)로 **이미 서버측 원장 정본 구현**. 셀러단은 **master `TB_USER`** 대상이라 해당 원장 부재 = SEC-VC-01.

## 1. 신설 테이블 `TB_AUTH_CODE` (master, 17→18)
**원칙: 클라엔 code_hash 절대 미노출 — 불투명 `request_id`만.** 대조 기준(code_hash)은 서버 DB에만.

| 컬럼 | 타입 | 규칙 |
|---|---|---|
| `id` | BIGINT AI PK | |
| `request_id` | VARCHAR(64) NOT NULL | 클라 반환 **불투명 참조키**(고엔트로피). **uk** |
| `purpose` | VARCHAR(20) NOT NULL | `signup`/`email_change`/`pw_reset` |
| `target_type` | VARCHAR(10) NOT NULL DEFAULT 'email' | 확장 여지 |
| `target` | VARCHAR(255) NOT NULL | 대상 이메일(서버 보유 → verify 시 클라 email 신뢰 제거) |
| `user_id` | BIGINT NULL | email_change/pw_reset 바인딩(TB_USER). signup=NULL |
| `code_hash` | VARCHAR(255) NOT NULL | `SHA-256(code + AUTH_CODE_PEPPER)`(서버전용 secret). **응답·로그 미포함** |
| `attempt_count` | INT NOT NULL DEFAULT 0 | verify 시도 카운터 |
| `max_attempts` | INT NOT NULL DEFAULT 5 | 시도 상한 |
| `expires_at` | TIMESTAMP NOT NULL | TTL(signup/email_change 600s·pw_reset 1800s, 05 C-2) |
| `consumed_at` | TIMESTAMP NULL | **1회성 소진** |
| `ip` | VARCHAR(64) NULL | 발급 IP(감사) |
| `code_state` | VARCHAR(12) NOT NULL DEFAULT 'active' | active/verified/consumed/expired/superseded/locked |
| `status` | INT NOT NULL DEFAULT 1 | 소프트삭제 컨벤션 |
| `created_at`,`updated_at` | TIMESTAMP | 컨벤션 |

**인덱스**: `uk_authcode_req(request_id)` · `idx_authcode_target(purpose,target,code_state)` · `idx_authcode_user(user_id)` · `idx_authcode_expires(expires_at)`.

**규칙**: 재발급=이전 활성행 `superseded` 후 신규 INSERT · verify마다 `attempt_count++`, `>=max_attempts`면 `locked`(재발급 강제) · 성공 시 `consumed_at=now, code_state='verified'` · 만료·소진·locked면 거부.

## 2. 토큰 흐름 재설계 (A5/A6 · A7/A8 공통)
```
issue  → 원장 INSERT(code_hash 서버저장) → 응답 { requestId, expiresIn }   (codeHash·issueToken 폐기)
verify → requestId 행조회 → 만료/소진/locked 체크 → attempt_count++ → code_hash 대조
       → 성공 시 consumed_at 기록 → verifyToken(email_verified 티켓) 발급
```
- **A5 응답 계약**: `{issueToken,expiresIn}` → `{requestId,expiresIn}`.
- **A6 요청 계약**: `{issueToken,email,code}` → `{requestId,code}`(email=서버 원장 target).
- verifyToken은 stateless 서명티켓 유지 가능(code_hash 미포함이라 무해; 원장 소진 연동은 선택 하드닝).
- code 원문은 **발송 게이트웨이로만**(응답·로그 금지). 오프라인탐색 불가·시도상한·1회성 **셋 다 서버 강제**.

## 3. 공유/단독 판정
**기능상 brand 단독(셀러 전용) — 셀러는 가입 시점 tenant 컨텍스트 없음(master TB_USER 대상). 학습자(tenant TB_MEMBER)와 다른 물리 스키마·계정 → 1테이블 공유 불가.**
**단, 물리 SoT(`solsol-api/db/migrations/000_master.sql` ↔ `docs/data-model/master.sql` byte-identical 미러)가 공유 → DDL 추가는 §4-2 허브 중재 필수**(3정본+ERD 동시 갱신·solsol-api 세션 통지). 테이블명은 tenant와 동일 `TB_AUTH_CODE`(멘탈모델 정합).

## 4. reset(A7/A8) 통합
**동일 `TB_AUTH_CODE`에 `purpose='pw_reset'` 흡수**(master 17→18, 별 테이블 신설 안 함). reset 토큰=고엔트로피 불투명(`code_hash=SHA-256(token+PEPPER)`), 1회성=`consumed_at` 핵심. 링크=`/reset?rid=<request_id>&t=<rawToken>`. **TB_USER 컬럼 추가 없음**(기존 password_updated_at 사용) → 공유 인증 테이블 DDL 트리거 아님. tenant는 reset 별 테이블 → ERD 비대칭은 주석 명시(향후 정렬 별건).

## 5. 허브 통지·해제조건
1. **ERD**: master 17→18(`TB_AUTH_CODE`), master.sql 카운트 주석·ERD.md·README 동시 갱신(허브 통합).
2. **물리 SoT 정합(dba)**: `docs/data-model/master.sql` + `solsol-api/db/migrations/000_master.sql`(솔솔 레포) + brand-api ORM 미러 `schema.master.ts` **동일 커밋 세트**. 000_master는 솔솔 영역 → 허브가 쏠쏠 세션에 미러 반영 통지. Aurora `solsol` 마이그=브랜드 DBA env.
3. **신규 시크릿**: `AUTH_CODE_PEPPER`(wrangler secret, 미설정 시 fail-closed). 하드코딩·로그·커밋 금지.
4. **계약 변경 통지**: A5/A6 issueToken→requestId → brand frontend 필드 수정.
5. **`_ledger` 해제조건(허브 단독)**: ① `TB_AUTH_CODE`(master) 도입 ② A5/A6 codeHash 클라반환 폐기·request_id·서버 code 대조 ③ A7/A8 원장 1회성 흡수 → **security(배보검)+privacy(노개보) 서명** 시 closed. 봉합 전 verify-code 운영배포 차단 유지.

## 6. 후속 실행 경계
- DDL/ORM authoring = **한데관(dba)**(master.sql+000_master 미러+schema.master.ts+마이그 멱등/롤백). A5~A8 재구현 = **조백개(api)**. 서명 = 배보검+노개보. 실 Aurora = 브랜드 DBA env. 커밋·배포 = 오너 "배포" 시(허브 단일 커밋 지점).
