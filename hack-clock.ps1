# Часы хакатона. Запускать в отдельном окне PowerShell в 0:00 и не закрывать до конца.
# .\hack-clock.ps1 -Start 13:30            (старт соревновательной части; по умолчанию текущее время)
# .\hack-clock.ps1 -Start 13:30 -Hours 5 -SubmitMinutesBeforeClose 20
param(
  [string]$Start = (Get-Date).ToString("HH:mm"),
  [int]$Hours = 5,
  [int]$SubmitMinutesBeforeClose = 20
)
$ErrorActionPreference = "Stop"
$startTime = [datetime]::ParseExact($Start, "HH:mm", $null)
$close = $startTime.AddHours($Hours)
$submit = $close.AddMinutes(-$SubmitMinutesBeforeClose)

$blocks = @(
  @{ from = 0;   to = 10;  name = "Блок 0: scaffold (агент). Эмина: тексты задач, PICK-TASK" },
  @{ from = 5;   to = 15;  name = "spec -> правка SPEC -> старт -> го. Эмина: task" },
  @{ from = 15;  to = 40;  name = "Блок 1: база, сид, таблица, Reset. Руками: блок 2, пустой деплой" },
  @{ from = 40;  to = 100; name = "Блок 3: чтение агентом, панель, трейс. Эмина: testdata" },
  @{ from = 100; to = 150; name = "Блок 4: запись с Approve, сценарий целиком. Эмина: readme" },
  @{ from = 150; to = 170; name = "Блок 5: валидация, лимиты, без ключа" },
  @{ from = 170; to = 195; name = "Блок 6: тесты, verify, docs/*.log" },
  @{ from = 195; to = 225; name = "Блок 7 руками: деплой + смоук с телефона. Эмина: readme, audit" },
  @{ from = 225; to = 255; name = "Блок 9: дизайн 15 мин, скриншот" },
  @{ from = 255; to = 280; name = "Блок 10: security-pass. Эмина: судья на своём ноутбуке, submit" },
  @{ from = 280; to = 300; name = "ФИНАЛ: последний пуш. Руки убрать." }
)

while ($true) {
  $now = Get-Date
  $elapsed = [int][math]::Floor(($now - $startTime).TotalMinutes)
  Clear-Host
  if ($elapsed -lt 0) {
    Write-Host ("ДО СТАРТА: {0} мин. Старт {1}, подача {2}, закрытие {3}" -f (-$elapsed), $startTime.ToString("HH:mm"), $submit.ToString("HH:mm"), $close.ToString("HH:mm")) -ForegroundColor Yellow
  } else {
    $h = [math]::Floor($elapsed / 60); $m = $elapsed % 60
    Write-Host ("ПРОШЛО {0}:{1:00}    СЕЙЧАС {2}    ПОДАЧА {3}    ЗАКРЫТИЕ {4}" -f $h, $m, $now.ToString("HH:mm"), $submit.ToString("HH:mm"), $close.ToString("HH:mm")) -ForegroundColor Cyan
    Write-Host ""
    foreach ($b in $blocks) {
      if ($elapsed -ge $b.from -and $elapsed -lt $b.to) {
        Write-Host ("СЕЙЧАС: {0}   (до {1}:{2:00})" -f $b.name, [math]::Floor($b.to / 60), ($b.to % 60)) -ForegroundColor Green
      }
    }
    Write-Host ""
    $minuteOfHour = $elapsed % 60
    if ($minuteOfHour -ge 50) {
      Write-Host "ЧЕКПОИНТ: Александр пишет «чекпоинт» (коммит + пуш того, что есть, ничего не удалять). Эмина пишет «progress»." -ForegroundColor Red
      [console]::beep(1000, 300)
    } else {
      Write-Host ("До чекпоинта: {0} мин" -f (50 - $minuteOfHour))
    }
    if ($elapsed -ge 150 -and $elapsed -lt 156) {
      Write-Host "2:30 ПРОВЕРКА: отстаём? Сценарий не проходит: упростить цель, уменьшить сид. Резать по порядку: GIF, дизайн, тесты до трёх, NVIDIA, Turso." -ForegroundColor Yellow
    }
    $toSubmit = [int][math]::Floor(($submit - $now).TotalMinutes)
    if ($toSubmit -gt 10) {
      Write-Host ("До подачи: {0} мин" -f $toSubmit)
    } elseif ($toSubmit -gt 0) {
      Write-Host ("ПОДАЧА через {0} мин: анкета в кабинете, последний пуш." -f $toSubmit) -ForegroundColor Red
      [console]::beep(1500, 500)
    } else {
      Write-Host "ПОДАЧА СЕЙЧАС. После неё ничего не трогать." -ForegroundColor Red
      [console]::beep(2000, 800)
    }
  }
  Start-Sleep -Seconds 30
}
