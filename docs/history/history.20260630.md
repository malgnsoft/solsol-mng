# 2026-06-30 — 크리에이터 LMS 데이터 모델·ERD·인증 슬라이스 + 모델 검증 2라운드

> **한 줄 요약** — 검증 정본(`docs/validation`)·양 목업을 분석해 **Aurora MySQL schema-per-tenant 데이터 모델**(master 14 + tenant 91 = 105테이블)을 설계·DDL화하고, Hyperdrive(`malgn-dev-solsol-prv`)로 dev DB(`solsol`=master / `solsol_lms`=tenant1)에 적용·검증. 모델을 검증정본 대비 **2라운드 적합성 검증(게이트 통과)**, **Figma ERD**(컬럼·자료형·PK(FK)·코멘트) 보드화, 인증(AUTH) 풀스택 슬라이스(프론트 화면 + API + mock E2E)까지 착수. 본 커밋은 **solsol-mng 문서**만 배포.

## 1. 데이터 모델 (Aurora MySQL · schema-per-tenant)

- 5개 도메인 병렬 분석(에이전트팀)으로 엔티티·필드·관계 추출 → 통합 DDL.
- **컨벤션**: `TB_` 단수 · `id BIGINT AUTO_INCREMENT PK` · `status INT(1/0/-1)` · 금액/크레딧 `DECIMAL(18,6)` · `DATETIME` UTC + 기본시 · **약한 FK**(네이밍+인덱스, 제약 없음) · utf8mb4.
- **schema-per-tenant**: 크리에이터 1=스키마 1. `master`(플랫폼↔크리에이터: 테넌트 레지스트리·셀러·SaaS구독·결제·크레딧) + `tenant_template`(사이트 운영 전체).
- dev 매핑(확정): master=`solsol`, 개발 테넌트=`solsol_lms`, 이후 `solsol_lms_<site_id>`.

## 2. Hyperdrive DB 연결·적용

- Cloudflare Hyperdrive `malgn-dev-solsol-prv`(id `a14c69…`, MySQL 8.0.42, 터널) 연결 검증(`wrangler dev --remote`). **USE 미지원** 확인 → 스키마 정규화 쿼리(`mysqlSchema(schema).table()`) 채택(OQ-DRZ 해소).
- `solsol-api`에 마이그레이션 러너 + `/ops/{reset,migrate,seed,verify}` 구축. dev DB 클린 리빌드 적용: master 14 / tenant 91 무오류 + 시드(셀러·테넌트).

## 3. 모델 적합성 검증 (Round 1·2)

- 4축(QA·보안·개인정보·DBA)으로 검증정본 대비 점검. **Round1**: blocker 7 식별. **교정**(토큰/코드 해시·정산프로필 소유자·`TB_REVIEW` 신설·암호화 요건·세션 UNIQUE 등) 후 클린 리빌드 재적용. **Round2**: ❌'상' 0건 → **게이트 통과**. 잔여는 중/하(앱계층·문서·biz-legal 트랙).

## 4. Figma ERD

- 마스터/테넌트 **별도 보드 2개**, 도메인별 다이어그램, 표기순 **컬럼명·자료형·PK(FK)·코멘트**.
- 마스터 v2 <https://www.figma.com/board/UR6M26ECZvEStba9rs3zVt> · 테넌트 v2 <https://www.figma.com/board/tds3QGtVLaj5InmKM56um5>

## 5. 인증(AUTH) 풀스택 슬라이스 — 착수(미배포)

- ADR `docs/architecture/AUTH_SPRINT1.md` + 클라우드 준비 체크리스트.
- 프론트 `solsol/`(신규 앱, 목업 동결): 로그인·가입·약관게이트·콜백·프로필/탈퇴 화면 + useAuth/useApi/미들웨어, 빌드 GREEN.
- API `solsol-api`: A1~A6 + M1~M7 + JWT/리프레시(해시·회전·재사용감지) + **mock provider E2E 11건 PASS**.
- ⏸ 운영 전: 소셜 5종 OAuth 키(OQ-OAUTH)·프론트↔API 실연동·인증 QA 라운드.

## 산출물

- `docs/data-model/`: `master.sql`·`tenant_template.sql`·`README.md`·`ERD.md`
- `docs/architecture/`: `AUTH_SPRINT1.md`·`CLOUD_PREREQUISITES.md`
- `docs/dev-validation/`: `data-model-vs-validation-round1.md`·`round2.md`·`BR01-brand-site-v3-round1.md`
- (별도 레포·미배포) `solsol-api` 인증 API, `solsol/` 신규 프론트 앱
- 본 배포: solsol-mng 문서 커밋·푸시(malgn). 앱 코드/콘텐츠 변경 없음 → Pages 재배포 생략.

## 다음 단계 / 알려진 한계

- 소셜 5종 OAuth 키 준비 → mock→실 provider 교체, 프론트↔API 실연동(`NUXT_PUBLIC_API_BASE`·refresh 쿠키 도메인).
- 인증 QA 라운드(화면ID 커버리지+9축) → `docs/dev-validation/auth-round1.md`.
- 인프라: 테넌트 자동 프로비저닝 전용 DB 계정(B-7). biz-legal: 국외이전·고유식별정보 수집근거.
- 모델 잔여 중/하: avg_rating 집계경로·instructor_user_id 명칭통일·subject_type default 등.
