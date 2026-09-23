# Проверка ноутбука к хакатону одной командой. Запускать после установки по EMINA-SETUP / ALEXANDER-SETUP:
#   pwsh -NoProfile -File C:\hack\agent-harness\check-laptop.ps1 -Role emina
#   pwsh -NoProfile -File C:\hack\agent-harness\check-laptop.ps1 -Role alexander
# Каждая строка: ОК, НЕТ (с командой исправления) или ?? (проверить глазами). Ничего не меняет, только читает.
param(
  [ValidateSet("alexander", "emina")]
  [string]$Role = "emina"
)
$ErrorActionPreference = "Continue"
$script:fail = 0
$script:warn = 0
function Ok([string]$m) { Write-Host "  ОК   $m" -ForegroundColor Green }
function Bad([string]$m, [string]$fix) {
  Write-Host "  НЕТ  $m" -ForegroundColor Red
  if ($fix) { Write-Host "       исправить: $fix" -ForegroundColor Yellow }
  $script:fail++
}
function Warn([string]$m, [string]$fix) {
  Write-Host "  ??   $m" -ForegroundColor Yellow
  if ($fix) { Write-Host "       $fix" }
  $script:warn++
}
function Out1([scriptblock]$b) {
  try { $r = & $b 2>$null | Select-Object -First 1; if ($null -eq $r) { return "" } else { return ([string]$r).Trim() } } catch { return "" }
}
function Section([string]$t) { Write-Host ""; Write-Host $t -ForegroundColor Cyan }

$who = if ($Role -eq "emina") { "Эмина" } else { "Александр" }
Write-Host "ПРОВЕРКА НОУТБУКА: $who ($(Get-Date -Format 'dd.MM HH:mm'))" -ForegroundColor Cyan

Section "Windows"
$tz = Get-TimeZone
if ($tz.BaseUtcOffset -eq [TimeSpan]::FromHours(5)) { Ok "часовой пояс UTC+5 ($($tz.Id))" } else { Bad "часовой пояс $($tz.BaseUtcOffset), нужен UTC+5 (Астана)" "Параметры -> Время и язык -> часовой пояс Астана" }
# У PowerShell 7 и 5.1 разные хранилища политики: смотрим фактическую политику здесь и CurrentUser у 5.1 отдельно.
$allowed = @("RemoteSigned", "Unrestricted", "Bypass")
$ep = [string](Get-ExecutionPolicy)
if ($ep -in $allowed) { Ok "ExecutionPolicy здесь (PowerShell $($PSVersionTable.PSVersion.Major)): $ep" } else { Bad "ExecutionPolicy здесь: $ep — скрипты комплекта не запустятся" "Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" }
if ($PSVersionTable.PSVersion.Major -ge 7) {
  $ep51 = Out1 { powershell.exe -NoProfile -Command "Get-ExecutionPolicy -Scope CurrentUser" }
  if ($ep51 -in $allowed) { Ok "ExecutionPolicy Windows PowerShell 5.1: $ep51" } elseif ($ep51) { Warn "Windows PowerShell 5.1: CurrentUser = $ep51 (нужно только если запускать .ps1 не через pwsh)" "в обычном Windows PowerShell: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" }
}
if (Get-Command pwsh -ErrorAction SilentlyContinue) { Ok "PowerShell 7: $(Out1 { pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' })" } else { Bad "нет PowerShell 7 (pwsh)" "winget install --id Microsoft.PowerShell --source winget" }

Section "Node и pnpm"
$node = Out1 { node -v }
if ($node -like "v22.*") { Ok "node $node" } elseif ($node) { Bad "node $node, нужен 22.x" "Node.js 22 LTS с nodejs.org" } else { Bad "node не найден" "Node.js 22 LTS с nodejs.org" }
$pnpm = Out1 { pnpm -v }
if ($pnpm -like "10.*") { Ok "pnpm $pnpm" } elseif ($pnpm) { Bad "pnpm $pnpm, нужен 10.x" "окно администратора: corepack prepare pnpm@10.34.5 --activate" } else { Bad "pnpm не найден" "окно администратора: corepack enable; corepack prepare pnpm@10.34.5 --activate" }
$npmGlobal = (npm ls -g --depth=0 2>$null | Out-String)
if ($npmGlobal -match "(?m)\snode@\d") { Bad "в глобальных npm-пакетах лишний 'node' (ломает git-bash)" "npm rm -g node" } else { Ok "лишнего npm-пакета node нет" }

Section "Git и GitHub"
$gitv = Out1 { git --version }
if ($gitv) { Ok $gitv } else { Bad "git не найден" "Git for Windows с gitforwindows.org" }
$gname = Out1 { git config --global user.name }
$gmail = Out1 { git config --global user.email }
if ($Role -eq "alexander") {
  if ($gname -eq "Alexander Kurchakov" -and $gmail -eq "fistin103@gmail.com") { Ok "git: $gname / $gmail" } else { Bad "git: '$gname' / '$gmail'" 'git config --global user.name "Alexander Kurchakov"; git config --global user.email "fistin103@gmail.com"' }
} else {
  if (-not $gname -or -not $gmail) { Bad "git: имя или почта не заданы" 'git config --global user.name "Эмина Ануарбекова"; git config --global user.email "<почта из github.com Settings Emails>"' }
  elseif ($gmail -eq "fistin103@gmail.com" -or $gname -eq "Alexander Kurchakov") { Bad "git стоит на Александра: '$gname' / '$gmail'" "поставить имя и почту Эмины (EMINA-SETUP, ШАГ 2)" }
  elseif ($gmail -match "example\.com|@test|ТВОЯ|ПОЧТА") { Bad "почта-заглушка: $gmail" "почта из github.com -> Settings -> Emails аккаунта Emina-An" }
  elseif ($gmail -match "noreply\.github\.com" -and $gmail -notmatch "Emina-An") { Bad "служебный адрес GitHub без логина Emina-An: $gmail" "вида 12345678+Emina-An@users.noreply.github.com" }
  else { Ok "git: $gname / $gmail"; Warn "что почта привязана к профилю Emina-An, git не знает" "после первого коммита на github.com у коммита должна быть аватарка Emina-An" }
}
$cred = (cmdkey /list 2>$null | Out-String)
$expectGh = if ($Role -eq "emina") { "Emina-An" } else { "Alexanderadon" }
# Блок записи git:https://github.com до следующей записи; поле пользователя по-английски или по-русски.
$ghUser = $null
$i = $cred.IndexOf("target=git:https://github.com")
if ($i -ge 0) {
  $rest = $cred.Substring($i + "target=git:https://github.com".Length)
  $next = $rest.IndexOf("target=")
  if ($next -ge 0) { $rest = $rest.Substring(0, $next) }
  $mu = [regex]::Match($rest, "(?:User|Пользователь)\s*:\s*(\S+)")
  if ($mu.Success) { $ghUser = $mu.Groups[1].Value }
}
if ($ghUser) {
  if ($ghUser -eq $expectGh) { Ok "Windows помнит GitHub как $ghUser" }
  else { Bad "Windows помнит GitHub как '$ghUser', нужен $expectGh" "cmdkey /delete:LegacyGeneric:target=git:https://github.com  и заново git push --dry-run origin main в C:\hack\lomra, войти как $expectGh" }
} else { Warn "сохранённого входа GitHub нет или не распознан" "появится после первого git clone репозитория команды; проверка права записи ниже всё равно покажет итог" }
$safe = (git config --system --get-all safe.directory 2>$null | Out-String)
foreach ($p in @("C:/hack/lomra", "C:/hack/agent-harness")) {
  if ($safe -match [regex]::Escape($p)) { Ok "safe.directory $p" } else { Warn "нет safe.directory $p (песочница Codex может ругаться на dubious ownership)" "окно администратора: git config --system --add safe.directory $p" }
}

Section "Папки и репозитории"
$kit = "C:\hack\agent-harness"
if (Test-Path "$kit\.git") {
  $null = git -C $kit fetch -q 2>$null
  $h = Out1 { git -C $kit rev-parse --short HEAD }
  $behind = Out1 { git -C $kit rev-list --count HEAD..origin/main }
  if ($behind -and [int]$behind -gt 0) { Bad "комплект отстаёт от GitHub на $behind коммит(ов)" "git -C $kit pull; pwsh -File C:/hack/agent-harness/install.ps1 -Role $Role" } else { Ok "комплект agent-harness актуален ($h)" }
} else { Bad "нет $kit" "cd C:\hack; git clone https://github.com/Alexanderadon/agent-harness" }
$team = "C:\hack\lomra"
if (Test-Path "$team\.git") {
  $origin = Out1 { git -C $team remote get-url origin }
  if ($origin -match "BAITC-Hacks/hack-463fe33c-lomra") { Ok "репозиторий команды: $team" } else { Bad "в $team чужой origin: $origin" "удалить папку и git clone https://github.com/BAITC-Hacks/hack-463fe33c-lomra lomra" }
  $dry = (git -C $team push --dry-run origin main 2>&1 | Out-String)
  if ($LASTEXITCODE -eq 0 -and $dry -match "up-to-date") { Ok "право записи в репозиторий команды (push --dry-run: Everything up-to-date)" }
  elseif ($dry -match "Repository not found") { Bad "Repository not found — Windows входит в GitHub чужим аккаунтом" "cmdkey /delete:LegacyGeneric:target=git:https://github.com, потом снова git push --dry-run origin main" }
  elseif ($dry -match "denied|403") { Bad "нет права записи в репозиторий команды" "писать организаторам: добавить $expectGh" }
  else { Warn "push --dry-run: $($dry.Trim())" "нет сети? повторить позже" }
  $status = (git -C $team status --porcelain 2>$null | Out-String).Trim()
  if ($status) { Warn "в репозитории команды есть незакоммиченные файлы" "до 13:00 ничего не создавать и не коммитить; проверить git -C $team status" } else { Ok "репозиторий команды чистый" }
} else { Bad "нет $team" "cd C:\hack; git clone https://github.com/BAITC-Hacks/hack-463fe33c-lomra lomra" }

Section "Codex"
$cx = Out1 { codex --version }
if ($cx) { Ok $cx } else { Bad "codex не найден" "npm i -g @openai/codex" }
if (Test-Path "$HOME\.codex\auth.json") { Ok "codex залогинен (auth.json есть)" } else { Warn "codex не залогинен" "codex login (без подписки — завтра в 12:30 перк-аккаунтом)" }
$cfgPath = "$HOME\.codex\config.toml"
if (Test-Path $cfgPath) {
  $cfg = [IO.File]::ReadAllText($cfgPath)
  if ($cfg -match '(?m)^sandbox_mode\s*=\s*"danger-full-access"' -and $cfg -match '(?m)^approval_policy\s*=\s*"never"') { Ok "codex config: danger-full-access + never (запись в .git работает)" }
  else { Bad "codex config без полного доступа — агент не сможет коммитить" "pwsh -File C:/hack/agent-harness/install.ps1 -Role $Role" }
} else { Bad "нет ~/.codex/config.toml" "pwsh -File C:/hack/agent-harness/install.ps1 -Role $Role" }
$roleFile = "$HOME\.codex\AGENTS.md"
$roleWord = if ($Role -eq "emina") { "Эмина, капитан" } else { "Александр, код" }
if ((Test-Path $roleFile) -and ([IO.File]::ReadAllText($roleFile, [Text.Encoding]::UTF8) -match [regex]::Escape($roleWord))) { Ok "роль в Codex: $roleWord" }
else { Bad "роль «$roleWord» не записана в ~/.codex/AGENTS.md (или кракозябры)" "pwsh -File C:/hack/agent-harness/install.ps1 -Role $Role" }

Section "Скиллы (Codex читает ~/.codex и ~/.agents, Claude — ~/.claude)"
if (Test-Path "$kit\skills") {
  $roots = @("$HOME\.codex\skills", "$HOME\.agents\skills", "$HOME\.claude\skills")
  $skills = Get-ChildItem "$kit\skills" -Directory
  foreach ($r in $roots) {
    $miss = 0; $diff = 0
    foreach ($s in $skills) {
      $src = Join-Path $s.FullName "SKILL.md"; $dst = Join-Path $r "$($s.Name)\SKILL.md"
      if (-not (Test-Path $dst)) { $miss++ } elseif ((Get-FileHash $src).Hash -ne (Get-FileHash $dst).Hash) { $diff++ }
    }
    if ($miss -eq 0 -and $diff -eq 0) { Ok "$r — $($skills.Count) скиллов совпадают с комплектом" }
    else { Bad "$r — нет $miss, устарело $diff" "pwsh -File C:/hack/agent-harness/install.ps1 -Role $Role, потом перезапустить Codex" }
  }
}

if ($Role -eq "alexander") {
  Section "Только Александр"
  $cl = Out1 { claude --version }
  if ($cl) { Ok "claude $cl" } else { Bad "claude CLI не найден" "npm i -g @anthropic-ai/claude-code" }
  $auth = (claude auth status 2>$null | Out-String)
  if ($auth -match '"loggedIn":\s*true') { Ok "claude CLI залогинен" } else { Bad "claude CLI не залогинен (вход в приложение не считается)" "claude auth login" }
  $vw = Out1 { vercel whoami }
  if ($vw -match "fistin103") { Ok "vercel: $vw" } else { Bad "vercel: '$vw'" "vercel logout; vercel login (аккаунт fistin103)" }
  if (Test-Path "$HOME\.claude\CLAUDE.md") {
    if ([IO.File]::ReadAllText("$HOME\.claude\CLAUDE.md", [Text.Encoding]::UTF8) -match "Александр, код") { Ok "роль в Claude: Александр, код" } else { Bad "роль Александра не записана в ~/.claude/CLAUDE.md" "pwsh -File C:/hack/agent-harness/install.ps1 -Role alexander" }
  }
}

Write-Host ""
if ($script:fail -eq 0) {
  Write-Host ("ИТОГ: ГОТОВО. Проблем нет, проверить глазами: {0}." -f $script:warn) -ForegroundColor Green
  if ($Role -eq "emina") {
    Write-Host "Последний шаг руками: в C:\hack\lomra  codex --sandbox danger-full-access --ask-for-approval never  и написать  Я Эмина, старт 13:00" -ForegroundColor Green
    Write-Host "Ждать отдельную строку «git: pull ок, запись в .git работает» и команды со словами «судья сборка» и «судья»." -ForegroundColor Green
  }
} else {
  Write-Host ("ИТОГ: ПРОБЛЕМ {0}, проверить глазами {1}. Исправить строки НЕТ сверху вниз и запустить проверку снова." -f $script:fail, $script:warn) -ForegroundColor Red
}
