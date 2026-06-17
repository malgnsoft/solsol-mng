import { defineConfig } from 'drizzle-kit'

// D1 스키마(참여자·간트·이슈) → 마이그레이션 생성.
//   pnpm db:generate  → server/db/migrations/*.sql 생성
//   적용(원격): pnpm db:apply (wrangler d1 migrations apply solsol-project --remote)
export default defineConfig({
  dialect: 'sqlite',
  schema: './server/db/schema.ts',
  out: './server/db/migrations',
})
