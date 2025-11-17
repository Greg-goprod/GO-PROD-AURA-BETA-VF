# Script d'audit d'uniformité du design system AURA (PowerShell)
# Usage: .\audit-uniformite.ps1 [chemin_optionnel]

param(
    [string]$TargetPath = "src\pages"
)

Write-Host "🔍 === AUDIT D'UNIFORMITÉ DESIGN SYSTEM AURA ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "📂 Analyse du répertoire: $TargetPath" -ForegroundColor Yellow
Write-Host ""

# 1. Icônes non standard
Write-Host "❌ === ICÔNES NON STANDARD ===" -ForegroundColor Red
Write-Host ""

Write-Host "🔸 Edit au lieu de Edit2:" -ForegroundColor Yellow
$editCount = 0
Get-ChildItem -Path $TargetPath -Recurse -Include *.tsx,*.ts | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'import.*\bEdit\b' -and $content -notmatch 'Edit2') {
        $editCount++
        Write-Host "  $($_.FullName)" -ForegroundColor Gray
    }
}
if ($editCount -eq 0) { Write-Host "  ✅ Aucun" -ForegroundColor Green }
Write-Host ""

Write-Host "🔸 Trash au lieu de Trash2:" -ForegroundColor Yellow
$trashCount = 0
Get-ChildItem -Path $TargetPath -Recurse -Include *.tsx,*.ts | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'import.*\bTrash\b' -and $content -notmatch 'Trash2') {
        $trashCount++
        Write-Host "  $($_.FullName)" -ForegroundColor Gray
    }
}
if ($trashCount -eq 0) { Write-Host "  ✅ Aucun" -ForegroundColor Green }
Write-Host ""

Write-Host "🔸 PlusCircle au lieu de Plus:" -ForegroundColor Yellow
$plusCircleCount = 0
Get-ChildItem -Path $TargetPath -Recurse -Include *.tsx,*.ts | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'PlusCircle') {
        $plusCircleCount++
        Write-Host "  $($_.FullName)" -ForegroundColor Gray
    }
}
if ($plusCircleCount -eq 0) { Write-Host "  ✅ Aucun" -ForegroundColor Green }
Write-Host ""

# 2. window.confirm
Write-Host "❌ === WINDOW.CONFIRM (utiliser ConfirmDialog) ===" -ForegroundColor Red
$confirmCount = 0
Get-ChildItem -Path $TargetPath -Recurse -Include *.tsx,*.ts | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'window\.confirm|[^/]confirm\(' -and $content -notmatch 'Confirm') {
        $confirmCount++
        Write-Host "  $($_.FullName)" -ForegroundColor Gray
    }
}
if ($confirmCount -eq 0) { Write-Host "  ✅ Aucun" -ForegroundColor Green }
Write-Host ""

# 3. Icônes mal placées
Write-Host "❌ === ICÔNES MAL PLACÉES (utiliser leftIcon) ===" -ForegroundColor Red
Write-Host ""

Write-Host "🔸 Plus avec className et mr:" -ForegroundColor Yellow
$plusBadCount = 0
Get-ChildItem -Path $TargetPath -Recurse -Include *.tsx | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '<Plus.*className.*mr') {
        $plusBadCount++
        Write-Host "  $($_.FullName)" -ForegroundColor Gray
    }
}
if ($plusBadCount -eq 0) { Write-Host "  ✅ Aucun" -ForegroundColor Green }
Write-Host ""

# 4. Hovers non standard
Write-Host "❌ === HOVERS NON STANDARD (utiliser var(--color-hover-row)) ===" -ForegroundColor Red
$hoverCount = 0
Get-ChildItem -Path $TargetPath -Recurse -Include *.tsx | Select-Object -First 10 | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'hover:bg-gray-50|hover:bg-gray-750') {
        $hoverCount++
        Write-Host "  $($_.FullName)" -ForegroundColor Gray
    }
}
if ($hoverCount -eq 0) { Write-Host "  ✅ Aucun" -ForegroundColor Green }
Write-Host ""

# Résumé
Write-Host "📊 === RÉSUMÉ ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Icônes Edit (devrait être Edit2): $editCount" -ForegroundColor $(if ($editCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "Icônes Trash (devrait être Trash2): $trashCount" -ForegroundColor $(if ($trashCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "Icônes PlusCircle (devrait être Plus): $plusCircleCount" -ForegroundColor $(if ($plusCircleCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "window.confirm (devrait être ConfirmDialog): $confirmCount" -ForegroundColor $(if ($confirmCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

$totalIssues = $editCount + $trashCount + $plusCircleCount + $confirmCount

if ($totalIssues -eq 0) {
    Write-Host "✅ Toutes les pages respectent les standards !" -ForegroundColor Green
} else {
    Write-Host "⚠️  Certaines pages nécessitent une mise à jour" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📚 Consultez MIGRATION_GUIDE_UNIFORMITE.md pour les corrections" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎨 Design System AURA - Audit terminé" -ForegroundColor Cyan










