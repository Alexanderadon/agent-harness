# Часы хакатона. В 12:50 отдельной вкладкой терминала, не закрывать до конца:
#   pwsh -NoProfile -File C:\hack\agent-harness\hack-clock.ps1 -Start 13:00
# Закрытие всегда -CloseAt (18:00, Положение 5.4.13), даже если старт сдвинулся: финал считается от закрытия.
# Проверка заранее: -Once печатает состояние и выходит; -ShiftMinutes N сдвигает «сейчас» на N минут.
#   pwsh -NoProfile -File hack-clock.ps1 -Start 13:00 -Once -ShiftMinutes ([int]((Get-Date '17:05') - (Get-Date)).TotalMinutes)
param(
  [string]$Start = (Get-Date).ToString("HH:mm"),
  [string]$CloseAt = "18:00",
  [int]$ShiftMinutes = 0,
  [switch]$Once
)
$ErrorActionPreference = "Stop"
# Имена переменных в PowerShell не различают регистр: внутренние даты названы иначе, чем параметры.
$startTime = [datetime]::ParseExact($Start, "HH:mm", $null)
$closeTime = [datetime]::ParseExact($CloseAt, "HH:mm", $null)
$noNewTime = $closeTime.AddMinutes(-90)      # 16:30 новое не начинать
$codeFreezeTime = $closeTime.AddMinutes(-60) # 17:00 код заморожен, судья
$deployFreezeTime = $closeTime.AddMinutes(-30) # 17:30 деплой заморожен, анкета отправлена
$lastPushTime = $closeTime.AddMinutes(-20)   # 17:40 последний пуш
$hashTime = $closeTime.AddMinutes(-15)       # 17:45 хеш сверен, дальше не пушить

# Блоки от старта, минуты (0:00 = старт). Финал ниже считается от закрытия.
$blocks = @(
  @{ from = 0;   to = 12;  name = "Блок 0: scaffold (9–12 мин). Эмина: Я Эмина, выбор задачи, task с критериями — скаффолд не ждать" },
  @{ from = 12;  to = 22;  name = "spec -> правка SPEC -> старт -> го. Эмина: вопросы. Руками ~0:25: vercel link, пустой деплой" },
  @{ from = 22;  to = 50;  name = "Блок 1: база, сид, таблица, Reset, /api/health" },
  @{ from = 50;  to = 100; name = "Блок 3: чтение агентом, маршрут, трейс. 0:50 чекпоинт + деплой (health: turso). 1:30 Эмина: readme" },
  @{ from = 100; to = 150; name = "Блок 4: запись с Approve, сценарий. 1:50 чекпоинт + деплой: 3 Run на URL. 2:00 Эмина: судья сборка" },
  @{ from = 150; to = 170; name = "ревью -> блок 5: валидация, лимиты, поведение без ключа" },
  @{ from = 170; to = 195; name = "Блок 6: тесты, verify, docs/*.log. 2:50 чекпоинт + деплой: МОДЕЛЬ ФИКСИРУЕТСЯ" },
  @{ from = 195; to = 210; name = "Блок 7 руками: деплой-кандидат, смоук. Агент: блок 9, дизайн не больше 15 мин. 3:15 Эмина: readme" },
  @{ from = 210; to = 100000; name = "ревью -> блок 10 security-pass" }
)

function Beep([int]$freq, [int]$ms) { if (-not $Once) { try { [console]::beep($freq, $ms) } catch { } } }

while ($true) {
  $now = (Get-Date).AddMinutes($ShiftMinutes)
  $elapsed = [int][math]::Floor(($now - $startTime).TotalMinutes)
  if (-not $Once) { Clear-Host }
  if ($elapsed -lt 0) {
    Write-Host ("ДО СТАРТА: {0} мин. Старт {1}, анкета до {2}, последний пуш {3}, закрытие {4}" -f (-$elapsed), $startTime.ToString("HH:mm"), $deployFreezeTime.ToString("HH:mm"), $lastPushTime.ToString("HH:mm"), $closeTime.ToString("HH:mm")) -ForegroundColor Yellow
  } else {
    $h = [math]::Floor($elapsed / 60); $m = $elapsed % 60
    Write-Host ("ПРОШЛО {0}:{1:00}    СЕЙЧАС {2}    ПОСЛЕДНИЙ ПУШ {3}    ЗАКРЫТИЕ {4}" -f $h, $m, $now.ToString("HH:mm"), $lastPushTime.ToString("HH:mm"), $closeTime.ToString("HH:mm")) -ForegroundColor Cyan
    Write-Host ""

    if ($now -ge $closeTime) {
      Write-Host "ЗАКРЫТО. Итоговая версия — репозиторий на $($closeTime.ToString('HH:mm')). Ничего не трогать." -ForegroundColor Red
    } elseif ($now -ge $hashTime) {
      Write-Host "ХЕШ сверен на GitHub с телефона? После $($hashTime.ToString('HH:mm')) не пушить никогда. Руки убрать." -ForegroundColor Red
      Beep 2000 800
    } elseif ($now -ge $lastPushTime) {
      Write-Host "ПОСЛЕДНИЙ ПУШ СЕЙЧАС: чекпоинт, git log origin/main -1 --format=%h, хеш Эмине." -ForegroundColor Red
      Beep 2000 800
    } elseif ($now -ge $deployFreezeTime) {
      Write-Host "ДЕПЛОЙ ЗАМОРОЖЕН: только vercel rollback. Анкета отправлена? $($closeTime.AddMinutes(-25).ToString('HH:mm')) Эмина: последний progress." -ForegroundColor Red
      Beep 1500 500
    } elseif ($now -ge $codeFreezeTime) {
      Write-Host "КОД ЗАМОРОЖЕН: финальный деплой при чистом git status. Эмина: судья, потом submit. Агенту только «Баг: …»." -ForegroundColor Red
      Beep 1500 500
    } elseif ($now -ge $noNewTime) {
      Write-Host "НОВОЕ НЕ НАЧИНАТЬ. ревью -> блок 10 security-pass. Эмина: живой URL x3, скриншоты, потом audit. Чекпоинт в :50." -ForegroundColor Yellow
    } else {
      foreach ($b in $blocks) {
        if ($elapsed -ge $b.from -and $elapsed -lt $b.to) {
          $until = if ($b.to -lt 100000) { " (до {0}:{1:00})" -f [math]::Floor($b.to / 60), ($b.to % 60) } else { "" }
          Write-Host ("СЕЙЧАС: {0}{1}" -f $b.name, $until) -ForegroundColor Green
        }
      }
    }
    Write-Host ""

    if ($elapsed -ge 100 -and $elapsed -lt 106) {
      Write-Host "1:40 ПРОВЕРКА: Run показывает трейс? Нет — отстаём на час, резать по MAP." -ForegroundColor Yellow
    }
    if ($elapsed -ge 150 -and $elapsed -lt 156) {
      Write-Host "2:30 ПРОВЕРКА: Approve есть? Нет — план «отстаём» из MAP: дизайн, второе чтение и баннер режутся, 5+6 одним блоком. Turso, URL, README, verify, судью не резать." -ForegroundColor Yellow
    }

    # Чекпоинт в :50 каждого часа, но только до последнего пуша (17:40): после него крика нет.
    $minuteOfHour = $elapsed % 60
    if ($now -ge $codeFreezeTime -and $now -lt $lastPushTime) {
      if ($now -lt $deployFreezeTime) { Write-Host ("До отправки анкеты ({0}): {1} мин" -f $deployFreezeTime.ToString("HH:mm"), [int][math]::Ceiling(($deployFreezeTime - $now).TotalMinutes)) -ForegroundColor Red }
      Write-Host ("До последнего пуша ({0}): {1} мин" -f $lastPushTime.ToString("HH:mm"), [int][math]::Ceiling(($lastPushTime - $now).TotalMinutes)) -ForegroundColor Yellow
    } elseif ($now -lt $lastPushTime) {
      if ($minuteOfHour -ge 50) {
        $deployNote = if ($elapsed -ge 230) { "деплоя НЕТ: финальный деплой в 4:00" } else { "потом деплой при чистом статусе" }
        Write-Host "ЧЕКПОИНТ: Александр пишет «чекпоинт» (коммит + пуш того, что есть, ничего не удалять), $deployNote. Эмина в :55 пишет «progress»." -ForegroundColor Red
        Beep 1000 300
      } else {
        Write-Host ("До чекпоинта: {0} мин" -f (50 - $minuteOfHour))
      }
    }
  }
  if ($Once) { break }
  Start-Sleep -Seconds 30
}
