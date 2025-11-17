@echo off
echo Verification des chemins d'import Timeline Booking...
echo.

echo Structure des dossiers:
echo src/
echo ├── components/
echo │   └── aura/
echo │       ├── Button.tsx
echo │       ├── Card.tsx
echo │       ├── Badge.tsx
echo │       ├── Modal.tsx
echo │       ├── Toast.tsx
echo │       ├── EmptyState.tsx
echo │       └── Input.tsx
echo └── features/
echo     └── timeline/
echo         ├── timelineApi.ts
echo         └── components/
echo             ├── TimelineGrid.tsx
echo             ├── PerformanceCard.tsx
echo             ├── DailySummaryCards.tsx
echo             └── CustomTimePicker.tsx
echo.

echo Chemins d'import corrects:
echo.
echo Depuis src/pages/LineupTimelinePage.tsx:
echo   ../components/aura/Button
echo   ../components/aura/Card
echo   ../components/aura/Badge
echo   ../components/aura/EmptyState
echo   ../components/aura/Toast
echo.
echo Depuis src/features/timeline/components/*.tsx:
echo   ../../../components/aura/Button
echo   ../../../components/aura/Card
echo   ../../../components/aura/Badge
echo   ../../../components/aura/Modal
echo   ../../../components/aura/Toast
echo   ../../../components/aura/EmptyState
echo   ../../../components/aura/Input
echo.

echo Verification des fichiers...
if exist "src\components\aura\Button.tsx" (
    echo ✅ Button.tsx existe
) else (
    echo ❌ Button.tsx manquant
)

if exist "src\components\aura\Card.tsx" (
    echo ✅ Card.tsx existe
) else (
    echo ❌ Card.tsx manquant
)

if exist "src\components\aura\Badge.tsx" (
    echo ✅ Badge.tsx existe
) else (
    echo ❌ Badge.tsx manquant
)

if exist "src\components\aura\Modal.tsx" (
    echo ✅ Modal.tsx existe
) else (
    echo ❌ Modal.tsx manquant
)

if exist "src\components\aura\Toast.tsx" (
    echo ✅ Toast.tsx existe
) else (
    echo ❌ Toast.tsx manquant
)

if exist "src\components\aura\EmptyState.tsx" (
    echo ✅ EmptyState.tsx existe
) else (
    echo ❌ EmptyState.tsx manquant
)

if exist "src\components\aura\Input.tsx" (
    echo ✅ Input.tsx existe
) else (
    echo ❌ Input.tsx manquant
)

echo.
echo Verification des composants Timeline...
if exist "src\features\timeline\timelineApi.ts" (
    echo ✅ timelineApi.ts existe
) else (
    echo ❌ timelineApi.ts manquant
)

if exist "src\features\timeline\components\TimelineGrid.tsx" (
    echo ✅ TimelineGrid.tsx existe
) else (
    echo ❌ TimelineGrid.tsx manquant
)

if exist "src\features\timeline\components\PerformanceCard.tsx" (
    echo ✅ PerformanceCard.tsx existe
) else (
    echo ❌ PerformanceCard.tsx manquant
)

if exist "src\features\timeline\components\DailySummaryCards.tsx" (
    echo ✅ DailySummaryCards.tsx existe
) else (
    echo ❌ DailySummaryCards.tsx manquant
)

if exist "src\features\timeline\components\CustomTimePicker.tsx" (
    echo ✅ CustomTimePicker.tsx existe
) else (
    echo ❌ CustomTimePicker.tsx manquant
)

echo.
echo ========================================
echo VERIFICATION TERMINEE
echo ========================================
echo.
echo Si tous les fichiers existent, les chemins d'import sont maintenant corrects.
echo.
pause

