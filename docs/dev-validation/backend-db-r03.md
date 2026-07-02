# backend-db-r03 — 관리자단 RBAC 역할기반 재작성 (허브 집계용)

> **라운드**: backend-db-r03 · **일자**: 2026-07-02 (KST) · **세션**: ① 공통 백엔드·데이터
> **프로파일**: 실연동 RBAC(보안 상시 + 마스킹) — **security·privacy 서명 필수**. 게이트 = security(배보검) **GO** · privacy(노개보) **GO**.
> **⚠️ `_ledger.md` 갱신은 허브 단독.** 본 파일은 결함표+close 근거.

## 1. 배경 — r02 NO-GO의 정정
r02에서 강사 RBAC가 security NO-GO(D-03/D-04)였으나, **직전 NO-GO 근거가 오류**였음이 확정됨:
- security가 근거로 든 `auth.ts:325` 주석("user_type 항상 staff")은 **스테일 주석**. **실제 토큰은 `signAccess({ typ: user.userType })`(auth.ts:1022 코드 검증)** → 강사 로그인 시 `typ='instructor'`.
- architect가 정본 인증모델 확정: user_type 3값(learner/instructor/staff), 서브강사=instructor+TB_ROLE.code=sub_instructor, 소유자=staff+owner. 요청시점 판별은 **user_type + TB_ROLE 파생(토큰 role 클레임 미추가)**.
- 진짜 결함은 "typ 불일치"가 아니라 **4역할 표현 부족·me.ts 게이트·서브강사 request-time 미배제·data_scope 무검증**이었음.

## 2. 재작성 내용 (조백개 · architect 정본 사양 + 오너 메뉴정책)
- **신규 SoT** `src/lib/role.ts`: `resolveEffectiveRole()`(owner/operator/instructor/sub_instructor/learner) + `resolveScope()`. auth.ts·me.ts·members.ts 이진 파생 수렴(운영자 오라벨 제거).
- **roleGuard.ts**: role 해석→`c.set('role')`, allowed 검사, **scope 코드강제**(owner=all·operator=저장값('none'=deny)·instructor/sub_instructor=**own 강제**), **서브강사 request-time 배제**(settlement·operation·users 403, 저장 allowed 무관).
- **me.ts:43**: 게이트 `('staff','instructor')`(강사 부트스트랩 blocker 해소). **auth.ts**: 스테일 주석 삭제·role 파생 교체.
- **라우트 게이트(오너 메뉴정책)**: 강사 허용=settlement AS-1~4·commerce AC-1/2·members AM-1/2·products(own) / 그 외(5종·쓰기·비가역·부가세) 운영자 전용.
- **commerce AC-2**: 강사=본인 item만 + 비례금액(교차강사 누출 교정).

## 3. 게이트 (재서명)
- **security(배보검) GO** — IDOR/권한상승 반증(own 코드강제·data_scope=all/none 오구성 무효화)·서브강사 request-time 403·배제 경계·AC-2·me 부트스트랩 전건 ⭕. blocker 0.
- **privacy(노개보) GO** — 마스킹 매핑 불변·비마스킹 잔존 0·AC-2 비례금액이 PII 경로 미신설.
- 정적검증: `npx tsc --noEmit` EXIT=0.

## 4. blocker close 보고 (허브 원장)
| 결함ID | 심각도 | 요약 | 상태 |
|---|---|---|---|
| BDB-r02-D03 | 상 | own 트리거/scope 무검증(IDOR) | **closed@r03** (roleGuard scope 코드강제) |
| BDB-r02-D04 | 상 | 배제 게이트 no-op(권한상승) | **closed@r03** (typ=instructor 실효 + 서브강사 request-time 배제) |
| BDB-r02-D01 | 상 | admin 라우트 own-scope 미구현 | **closed@r03** (roleGuard own 강제 + 라우트 own 필터) |
| RB-04(AC-2) | 중 | 주문상세 교차강사 누출 | closed@r03 |

## 5. 잔존·후속 (비차단)
| ID | 심각도 | 요약 | 담당 |
|---|---|---|---|
| RBAC-OBS-1 | 하 | operator 저장 scope 미인식/공백 시 'all' 기본(fail-open). 신뢰 스태프·allowed 게이트 전제라 영향 제한, 단 defensive default(deny/명시) 권고 — trade-off(미설정 operator 과제한 위험) 있어 정책 확인 후 반영 | api/기획 |
| RBAC-MENU-1 | 중 | 서브강사 members-read(AM-1/2)가 menu_key `users` 공유로 403(수강생 조회 불가). 부여하려면 menu_key 분리(`members` vs `users`) = DDL/설계 | dba/기획 |
| FRONT-CONTRACT-1 | 중 | `/auth/login`·`/admin/me` 응답 `role` 도메인 확장(owner/operator/instructor/sub_instructor/learner) → solsol-admin(②) BFF 형상 일치 필요 | ② 조율 |

## 6. 배포 전 확인 (실 DB 스모크)
security 권고: 배포 전 강사·서브강사·운영자·오너 4역할 대상 목록/상세/카운트·403 경계 각 1회 실 DB 스모크. TB_ADMIN_PERMISSION 실 시드가 강사 최소권한만 부여하는지 확인.
