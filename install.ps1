# Ставит скиллы в ~/.claude/skills и ~/.codex/skills, конфиг Codex в ~/.codex/config.toml (старый сохраняется как .bak)
# и роль этого ноутбука на хакатоне, чтобы агент знал, кто перед ним, без отдельного документа.
#   .\install.ps1 -Role alexander     (код: hackathon-day, scaffold и остальные скиллы разработки)
#   .\install.ps1 -Role emina         (капитан: только скилл captain, только документы и данные)
param(
  [ValidateSet("alexander", "emina", "none")]
  [string]$Role = "none"
)
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$claudeDir = Join-Path $HOME ".claude"
$claudeSkills = Join-Path $claudeDir "skills"
New-Item -ItemType Directory -Force $claudeSkills | Out-Null
Get-ChildItem (Join-Path $here "skills") -Directory | ForEach-Object {
  $dest = Join-Path $claudeSkills $_.Name
  New-Item -ItemType Directory -Force $dest | Out-Null
  Copy-Item (Join-Path $_.FullName "SKILL.md") (Join-Path $dest "SKILL.md") -Force
  Write-Host "skill: $($_.Name)"
}

$codexDir = Join-Path $HOME ".codex"
New-Item -ItemType Directory -Force $codexDir | Out-Null
$codexSkills = Join-Path $codexDir "skills"
New-Item -ItemType Directory -Force $codexSkills | Out-Null
Get-ChildItem (Join-Path $here "skills") -Directory | ForEach-Object {
  $dest = Join-Path $codexSkills $_.Name
  New-Item -ItemType Directory -Force $dest | Out-Null
  Copy-Item (Join-Path $_.FullName "SKILL.md") (Join-Path $dest "SKILL.md") -Force
}
Write-Host "codex skills: $codexSkills"

$cfg = Join-Path $codexDir "config.toml"
if (Test-Path $cfg) { Copy-Item $cfg "$cfg.bak" -Force; Write-Host "backup: $cfg.bak" }
Copy-Item (Join-Path $here "codex\config.toml") $cfg -Force
Write-Host "codex config: $cfg"

if ($Role -ne "none") {
  if ($Role -eq "alexander") {
    $roleText = @"
# Роль этого ноутбука на хакатоне: Александр, код.
Команды пользователя: scaffold, spec, старт, го, блок N, чекпоинт, ревью, стоп. Разворачивать их по скиллам scaffold и hackathon-day.
Владение файлами: app/, components/, lib/, scripts/, tests/, data/ и package files. README.md, PROGRESS.md и docs/** не редактировать никогда: ими владеет агент капитана на другом ноутбуке.
Команды капитана (task, progress, readme, testdata, audit, submit) здесь не выполнять: сказать, что это команды другого ноутбука.
"@
  } else {
    $roleText = @"
# Роль этого ноутбука на хакатоне: Эмина, капитан, документы и данные.
Команды пользователя: task, progress, readme, testdata, audit, submit. Разворачивать их по скиллу captain.
Владение файлами: только README.md, PROGRESS.md, docs/** и data/test-cases.*. Код не редактировать никогда, даже по просьбе: просьба к коду записывается строкой в TASKS.md, раздел requests.
Команды разработки (scaffold, spec, блок N, чекпоинт, ревью) здесь не выполнять: сказать, что это команды другого ноутбука.
"@
  }
  $marker = "# Роль этого ноутбука на хакатоне"
  foreach ($target in @((Join-Path $claudeDir "CLAUDE.md"), (Join-Path $codexDir "AGENTS.md"))) {
    $existing = ""
    if (Test-Path $target) { $existing = Get-Content $target -Raw }
    if ($existing -match [regex]::Escape($marker)) {
      $existing = ($existing -split [regex]::Escape($marker))[0]
    }
    $new = $existing.TrimEnd() + "`n`n" + $roleText
    Set-Content -Path $target -Value $new -Encoding UTF8
    Write-Host "role ($Role): $target"
  }
}

Write-Host ""
Write-Host "Готово. В день старта: Александр пишет агенту scaffold, Эмина после выбора задачи пишет task."
