# 백엔드·DB (backend-db) 트랜스크립트 — 2026-07-02

> **성격**: 이 파일은 **프롬프트 + 에이전트 대화 이력**만 기록한다. **작업이력은 `docs/history/history.20260702.md` §8**, 결함표·판정은 `docs/dev-validation/backend-db-*.md`.
> 세션: 쏠쏠 백엔드·DB(공유 데이터 정본 단독 소유) · 시크릿·PII는 위치·유형만.

---

## 1. 사용자(오너) 프롬프트

1. "쏠쏠·쏠쏠브랜드 백엔드/DB 관리. solsol-mng MD 분석·영역 숙지. 글로벌 에이전트팀·글로벌 지시/보고 체계. 참여 에이전트 보고."
2. "DEV_SESSION_PROTOCOL.md 먼저 읽고 세션 레인(①/②/③) 확인하라."
3. "샘플데이터를 충분히 넣어 테스트할 때 목업이 아니라 DB 데이터를 볼 수 있도록."
4. (착수) "백엔드·DB 세션 총괄. 목표: 데이터 정본 단일화(4자) + DAT-D01·DAT-D02·r03-D02 + API 계약 발행(/doc). 허브 보고. transcripts 기록."
5. "맘대로 총괄이 최대한 많은 에이전트와 계획대로 진행."
6. "[샘플 데이터 시드 + 계약 발행] 도메인 대표+엣지케이스. IMPLEMENTATION_STANDARD §2·§4 + ERD 선독. 데이터 5축. 허브 보고. transcripts 기록."
7. "다음 진행."
8. "transcripts는 프롬프트·대화 이력 파일, 작업이력은 history에."

## 2. 에이전트 소통 이력 (총괄 ↔ 팀장 ↔ 팀원 · 시간순)

> 형식: **총괄 지시 요지 → 담당(이름) 회신 요지.** 산출 상세는 history §8 참조.

### R1 — 정본 단일화 + 6 blocker (착수)
- 총괄→**조남기(dev-lead)**: 6 blocker 실행계획(분해·담당·순서·리스크·완료기준). ← 의존성 그래프(DAT-D01→r03-D02→SEC-1 직렬 / SEC-r02-D01·PRV-r02-D01 독립)·W1~W5 회신.
- 총괄→**architect**: 정본 단일화 결정. ← 단일 TB_CREDIT 정본·브랜드 3테이블 마스터 존치·기준선=`000_master.sql`·오너확인 불요 회신.
- 총괄→**한데관(dba)** W1: 스키마 4자 동기 스윕. ← 6파일 동기·마이그 002·tsc EXIT0.
- 총괄→**조백개(api)** W4/W5/W2/W3: health 게이트·PII 마스킹·크레딧 단일모델·SEC-1 원자화. ← W4·W5 워킹트리 반영 확인 / W2 정합+멱등키 방어 / **W3 SEC-1 부분미해소 발견→단일 tx+FOR UPDATE+INSERT-first 재구성**.
- 총괄→**배보검(security)**: SEC-1·health·크레딧 서명. ← 3건 ⭕(잔존 중=파생잔액 비직렬화). 총괄→**노개보(privacy)**: PII 마스킹. ← ⭕(하=maskEmail 1자). 총괄→**오품관(qa)**: 정적·계약·회귀. ← GO.
- 총괄→**조백개(api)** W6: 파생잔액 직렬화·maskEmail 2자. ← lockedBalance 도입·tsc EXIT0. → **배보검** 재서명 ⭕(신규 하=데드락 락순서).
- 총괄→**조백개(api)**: 계약 발행 확인. ← 양 /doc 실재·프리즈 노트(brand admin 카탈로그 갭 지적).

### R2 — DB 미결 실행 + 샘플시드 강화 + 계약
- 총괄→**한데관(dba)·조남기(dev-lead)**: 3리포트 DB 항목 취합·실행계획·절차. ← 5웨이브·오너대기 12건·절차(`/ops` 경유·GRANT·4자동기) 회신(`plan-r01`).
- 총괄→(병렬) **한데관**(스키마 스윕 TB_SESSION·is_secret·명명·마이그 003/004) · **조백개**(Blocker A=이미 해소 확인·무편집 / 데드락 락순서 / brand `/doc` 34EP) · **한데관**(브랜드 운영자 시드=`/ops/seed-admin` 런타임 PBKDF2 GO·정적 .FINAL 불요). ← 전건 완료·tsc EXIT0. **조백개 특기: 강사 `instructor`가 `requireUserType('staff')` 403 → 데이터모델 결정 필요(총괄 라우팅).**
- 총괄→**한데관**(샘플시드 강화 엣지 5종) · **조백개**(계약 프리즈 노트). ← master 389·tenant 820행·원장 SUM 검산 / solsol-api 223EP·brand-api 77EP·totalPages 보정.
- 총괄→**오품관(qa)**: 데이터 5축 게이트. ← **GO**(advisory: 홍길동 안전 테스트값).

### R3 — 강사 RBAC own-스코프 (오너 "다음 진행")
- 총괄→**조백개(api)**: 강사 RBAC 게이트 정합(05#3). ← **권한상승 방지로 products만 완화**·나머지 8라우트 **own-scope 미구현(D-2 blocker)** 발견·보류.
- 총괄→**조남기(dev-lead)**: 도메인별 own-스코프 사양. ← 스키마상 own 성립=**정산·주문·수강생 3종뿐**·5종은 owner컬럼 부재(기획결정)·서브강사 제외 코드강제 갭(P-2) 회신.
- 총괄→**오너**(AskUserQuestion): 강사 메뉴범위·PII·수강생 권한. ← **정산·주문·수강생 3종만·마스킹 유지·조회전용** 확정.
- 총괄→**조백개(api)**: 3종 own-스코프 구현. ← EXISTS 서버강제·배제 유지·서브강사 거부·tsc EXIT0 회신(AM-3=상태변경 배제 처리).
- 총괄→**배보검(security)**: RBAC 서명. ← **NO-GO(blocker 2)** — 인증모델 불일치(강사 typ='staff'+TB_ROLE 파생 vs typ='instructor' 전제)로 own 트리거 사문화·배제 no-op. 역할기반 재작성 권고.
- 총괄→**노개보(privacy)**: 마스킹 서명. ← **GO**(scope 무관 마스킹 무조건 유지·비마스킹 잔존 0).
- 총괄 판정(r02): 강사 RBAC **보류**. → R4로 재작성.

### R4 — 강사 RBAC 역할기반 재작성 (오너 "차례로 진행")
- 총괄→**architect**: 인증모델 정본 확정(typ vs TB_ROLE 상충). ← **security가 스테일 주석 오독**·실제 토큰 typ=user_type(auth.ts:1022)·정본모델(user_type 3값+TB_ROLE 파생)·재작성 사양·유일쟁점(operation/settlement 강사개방)=오너 Q1로 해소 회신.
- 총괄 코드 직접확인: `auth.ts:1022 signAccess({typ:user.userType})` 확정.
- 총괄→**조백개(api)**: 역할기반 재작성(resolveEffectiveRole·roleGuard scope 코드강제·서브강사 request-time 배제·me 게이트·AC-2 교정). ← RB-01~06 해소·tsc EXIT0·서브강사 members-read menu_key 공유 이슈 플래그·프론트 role 도메인 확장 알림 회신.
- 총괄→**배보검(security)** 재서명: ← **GO**(정정모델 확인·IDOR/권한상승 차단·blocker 0·하 1=operator fail-open). 총괄→**노개보(privacy)** 재확인: ← **GO**(마스킹 불변).
- 총괄 판정: 강사 RBAC **close(GO)**. 결함표=`dev-validation/backend-db-r03.md`. 상세·산출=history §8.
