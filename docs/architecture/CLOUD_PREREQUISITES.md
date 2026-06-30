# 클라우드 선행 준비 체크리스트 — 인증(AUTH) 풀스택 착수 전 (Definition of Ready)

[AUTH_SPRINT1.md](AUTH_SPRINT1.md) 아키텍처를 **실연동 기준**으로 빌드하기 위한 외부·인프라 준비물.
이 항목들이 갖춰지면 Wave-1(스캐폴드+DB+인증) 빌드를 실서비스 연결로 시작한다.
(긴급히 먼저 만들고 싶다면 로컬 dev 모드 — Docker MySQL + `X-Tenant` 헤더 — 로도 병행 가능)

> 상태 표기: ☐ 미완 / ☑ 완료. 각 항목의 **산출(우리가 받아야 할 값)** 을 채워 주세요.

---

## A. Aurora MySQL (DB)

- ☐ **클러스터 프로비저닝** — Aurora MySQL **8.0 호환**, 리전 결정(예: `ap-northeast-2` 서울), 인스턴스 클래스(개발 `db.t4g.medium`~), Multi-AZ 여부.
- ☐ **접속 자격** — 마스터 사용자/비밀번호, 엔드포인트(writer/reader), 포트(3306).
- ☐ **네트워킹(중요)** — Hyperdrive가 붙으려면 DB가 **외부에서 도달 가능**해야 함. 택1:
  - (권장) **Cloudflare Tunnel** 로 프라이빗 VPC의 Aurora를 노출(공개 IP 불필요, 보안 우수), 또는
  - Aurora **퍼블릭 엑세스 + TLS + 보안그룹 화이트리스트**.
- ☐ **스키마 적용** — `docs/data-model/master.sql` → `solsol_master`, `tenant_template.sql` → 최초 테넌트 스키마(예: `solsol_t000001`).
- ☐ **앱 전용 DB 계정** — 마스터 말고 권한 최소화 계정(필요 스키마 GRANT). schema-per-tenant라 **여러 스키마 SELECT/DML 권한** 필요.

**받아야 할 값**: writer 엔드포인트 · 포트 · 앱 계정 ID/PW · 적용 완료된 스키마명들.

---

## B. Cloudflare Hyperdrive

- ☐ **MySQL 지원/한도 확인** — Hyperdrive의 MySQL 지원 정식/베타 여부·한도를 콘솔/문서에서 1회 확인(⚠️ OQ-HD, 미지원이면 Workers→DB 직접 연결 또는 대체 풀러로 폴백).
- ☐ **Hyperdrive config 생성** — A의 접속 정보로 origin 연결(기본 스키마=`solsol_master` 권장). **테넌트마다 config 만들지 않음** — 한 config로 클러스터에 붙고 쿼리에서 `<schema>.TB_*`로 정규화.
- ☐ **Workers 바인딩** — `solsol-api`의 `wrangler.toml`에 Hyperdrive 바인딩 추가(빌드 시 우리가 작성, 바인딩 ID만 받으면 됨).

**받아야 할 값**: Hyperdrive 바인딩 ID · 연결 검증 결과(쿼리 1회 성공).

---

## C. 소셜 OAuth 5종 (AUTH-01)

각 provider 앱 등록 후 **리다이렉트 URI**를 서버 콜백으로 지정. 패턴(서버사이드 교환):
`https://api.<도메인>/api/auth/callback/{provider}` (+ 로컬: `http://localhost:8787/api/auth/callback/{provider}`)

- ☐ **Google** — OAuth 2.0 Client ID/Secret, 승인된 리디렉션 URI, 동의화면.
- ☐ **Kakao** — REST API 키, Redirect URI, 동의항목(닉네임/이메일).
- ☐ **Naver** — Client ID/Secret, Callback URL, 검수(이메일 권한).
- ☐ **Apple** — Service ID(client_id) · Team ID · Key ID · **.p8 Private Key**(client_secret JWT 생성용) · Return URL. (가장 까다로움 — 리드타임)
- ☐ **Facebook** — App ID/Secret, Valid OAuth Redirect URI, **앱 심사**(public_profile/email). (심사 리드타임)

**받아야 할 값**: provider별 Client ID/Secret(애플은 .p8+Team/Key ID) · 등록한 리다이렉트 URI.

---

## D. 도메인 · 테넌트 매핑

- ☐ **프론트 도메인** — 사용자단 사이트 도메인(테넌트 사이트). 최소 1개(예: 첫 크리에이터 도메인 또는 `*.solsol.app` 서브도메인).
- ☐ **API 도메인** — `api.<도메인>`(Workers 라우트/커스텀 도메인).
- ☐ **테넌트 등록** — `master.TB_TENANT`에 행 1개: `slug` · `schema_name`(=B에서 적용한 스키마) · `domain`(D의 프론트 도메인) · owner. → host→스키마 라우팅의 정본.

**받아야 할 값**: 프론트 도메인 · API 도메인 · 최초 테넌트(slug/도메인/스키마) 1세트.

---

## E. 시크릿 / 환경변수 (빌드 시 우리가 배선, 값만 주입)

**solsol-api (Workers — `wrangler secret put`)**
- `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`
- `DB_APP_USER`, `DB_APP_PASSWORD`(또는 Hyperdrive 연결문자열에 포함), `DB_HOST`, `DB_PORT`
- `GOOGLE_CLIENT_ID/SECRET`, `KAKAO_CLIENT_ID/SECRET`, `NAVER_CLIENT_ID/SECRET`,
  `APPLE_CLIENT_ID/TEAM_ID/KEY_ID/PRIVATE_KEY`, `FACEBOOK_APP_ID/APP_SECRET`
- `OAUTH_REDIRECT_BASE`(예: `https://api.<도메인>`)
- (바인딩) `HYPERDRIVE`, (선택) `FILES` R2 버킷

**solsol (Pages — 환경변수)**
- `NUXT_PUBLIC_API_BASE`(예: `https://api.<도메인>`)

---

## F. 발주자가 결정할 항목

- ☐ AWS **리전**(지연·비용) — 권장 서울(`ap-northeast-2`).
- ☐ Aurora **연결 방식** — Cloudflare Tunnel(권장) vs 퍼블릭+화이트리스트.
- ☐ 도메인 전략 — 크리에이터별 커스텀 도메인 vs 공용 서브도메인(`*.`).
- ☐ 소셜 5종 **전부 1차 오픈** vs 일부(예: Google/Kakao) 먼저 + 나머지 후속.

---

## 준비 완료 후 → Wave-1 빌드 착수

위 A~E가 채워지면 에이전트팀이 병렬 착수:
1. **dba** — Drizzle 스키마(auth 테이블) + 마이그레이션 + 스키마 정규화 스파이크(B2)
2. **api-developer** — Hono/Workers 골격 + 테넌트 해석 미들웨어 + 소셜 콜백/세션 + Hyperdrive 연결
3. **frontend-developer** — Nuxt 앱 골격(루트, mockup 무수정) + 인증 화면 + API 연동
4. **게이트** — 9축 셀프체크 → qa·security·privacy → ❌'상' 0건 → 기록(`docs/dev-validation/`)

> ⚠️ 목업 동결: `solsol/mockup`·`solsol-admin/mockup`은 비교 기준선 — 수정 금지. 신규 앱은 레포 루트.
