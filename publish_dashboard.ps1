# publish_dashboard.ps1
# Копирует последний сгенерированный дашборд в репозиторий и публикует на GitHub Pages.
#
# Использование:
#   .\publish_dashboard.ps1                          # найти последний dashboard_*.html автоматически
#   .\publish_dashboard.ps1 -Path "D:\...\file.html" # указать файл явно

param(
    [string]$Path = ""
)

$REPO_DIR     = $PSScriptRoot
$SEARCH_ROOT  = "D:\Analyses\Ключи Ceramic"
$REMOTE_URL   = "https://github.com/TatkovDmitriy/Ceramic3D_keys"

# ── 1. Найти HTML-файл дашборда ──────────────────────────────────────────────
if ($Path -ne "") {
    $src = $Path
} else {
    $found = Get-ChildItem -Path $SEARCH_ROOT -Recurse -Filter "dashboard_*.html" -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -notlike "*\.ipynb_checkpoints\*" } |
             Sort-Object LastWriteTime -Descending |
             Select-Object -First 1

    if (-not $found) {
        Write-Host "❌ Файлы dashboard_*.html не найдены в $SEARCH_ROOT"
        Write-Host "   Сначала запусти ноутбук (ячейка «Экспорт HTML-дашборда»)."
        exit 1
    }
    $src = $found.FullName
}

if (-not (Test-Path $src)) {
    Write-Host "❌ Файл не найден: $src"
    exit 1
}

Write-Host "📄 Публикую: $src"

# ── 2. Копируем в репозиторий как index.html ─────────────────────────────────
Copy-Item $src -Destination "$REPO_DIR\index.html" -Force

# ── 3. Git commit + push ─────────────────────────────────────────────────────
Set-Location $REPO_DIR

git add index.html | Out-Null

$dateLabel = (Get-Date).ToString('dd.MM.yyyy HH:mm')
$srcName   = (Get-Item $src).Name
git commit -m "dashboard: $srcName ($dateLabel)" 2>&1

$pushResult = git push origin main 2>&1
Write-Host $pushResult

# ── 4. Итог ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "✅ Готово! Дашборд опубликован:"
Write-Host "   $REMOTE_URL"
Write-Host "   https://tatkovdmitriy.github.io/Ceramic3D_keys/"
Write-Host ""
Write-Host "   (Если GitHub Pages ещё не включён: Settings > Pages > main / root)"
