# Прогрев ноутбука: один раз до хакатона. Ставит в кэш pnpm все пакеты, которые понадобятся в день,
# и проверяет, что create-next-app и shadcn работают без вопросов. Папка после проверки удаляется.
$ErrorActionPreference = "Stop"
$tmp = Join-Path $env:TEMP "prewarm-next"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }

Write-Host "1/4 create-next-app"
pnpm create next-app@latest $tmp --ts --tailwind --eslint --app --no-src-dir --import-alias "@/*" --use-pnpm --yes
Set-Location $tmp

Write-Host "2/4 shadcn"
pnpm dlx shadcn@latest init -y -d
pnpm dlx shadcn@latest add -y button card badge table skeleton input textarea scroll-area separator

Write-Host "3/4 deps"
pnpm add ai @ai-sdk/openai @ai-sdk/react @ai-sdk/openai-compatible zod @libsql/client lucide-react
pnpm add -D vitest tsx @types/node

Write-Host "4/4 typecheck + build"
pnpm exec tsc --noEmit
pnpm build

Set-Location $env:TEMP
Remove-Item -Recurse -Force $tmp
Write-Host ""
Write-Host "Прогрев прошёл: все пакеты в кэше pnpm, скаффолд и сборка работают."
