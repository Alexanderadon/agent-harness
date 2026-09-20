# Ставит скиллы в ~/.claude/skills и конфиг Codex в ~/.codex/config.toml (старый сохраняется как .bak).
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$claudeSkills = Join-Path $HOME ".claude\skills"
New-Item -ItemType Directory -Force $claudeSkills | Out-Null
Get-ChildItem (Join-Path $here "skills") -Directory | ForEach-Object {
  $dest = Join-Path $claudeSkills $_.Name
  New-Item -ItemType Directory -Force $dest | Out-Null
  Copy-Item (Join-Path $_.FullName "SKILL.md") (Join-Path $dest "SKILL.md") -Force
  Write-Host "skill: $($_.Name)"
}

$codexDir = Join-Path $HOME ".codex"
New-Item -ItemType Directory -Force $codexDir | Out-Null
$cfg = Join-Path $codexDir "config.toml"
if (Test-Path $cfg) { Copy-Item $cfg "$cfg.bak" -Force; Write-Host "backup: $cfg.bak" }
Copy-Item (Join-Path $here "codex\config.toml") $cfg -Force
Write-Host "codex config: $cfg"

Write-Host ""
Write-Host "Дальше руками после старта: скопировать AGENTS.md, CLAUDE.md и templates/* в репозиторий проекта."
