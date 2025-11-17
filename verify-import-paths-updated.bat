@echo off
echo Verification des chemins d'import Timeline Booking...
echo.

echo Structure des dossiers:
echo src/
echo ├── lib/
echo │   ├── supabaseClient.ts
echo │   └── utils.ts
echo ├── components/
echo │   └── aura/
echo │       ├── Button.tsx
echo │       ├── Card.tsx
echo │       ├── Badge.tsx
echo │       ├── Modal.tsx
echo │       ├── Toast.tsx
echo │       ├── EmptyState.tsx
echo │       └── Input.tsx
echo ├── pages/
echo │   └── LineupTimelinePage.tsx
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
echo   ../features/timeline/components/TimelineGrid
echo   ../features/timeline/components/DailySummaryCards
echo   ../features/timeline/components/CustomTimePicker
echo   ../features/booking/modals/PerformanceModal
echo   ../features/timeline/timelineApi
echo.
echo Depuis src/features/timeline/timelineApi.ts:
echo   ../../lib/supabaseClient
echo.
echo Depuis src/features/timeline/components/*.tsx:
echo   ../../../components/aura/Button
echo   ../../../components/aura/Card
echo   ../../../components/aura/Badge
echo   ../../../components/aura/Modal
echo   ../../../components/aura/Toast
echo   ../../../components/aura/EmptyState
echo   ../../../components/aura/Input
echo   ../timelineApi
echo.

echo Verification des fichiers critiques...
if exist "src\lib\supabaseClient.ts" (
    echo ✅ supabaseClient.ts existe
) else (
    echo ❌ supabaseClient.ts manquant
)

if exist "src\lib\utils.ts" (
    echo ✅ utils.ts existe
) else (
    echo ❌ utils.ts manquant
)

echo.
echo Verification des imports dans timelineApi.ts...
findstr /C:"../../lib/supabaseClient" src\features\timeline\timelineApi.ts >nul
if %errorlevel%==0 (
    echo ✅ Import supabaseClient correct
) else (
    echo ❌ Import supabaseClient incorrect
)

echo.
echo Verification des imports dans les composants...
findstr /C:"../../../components/aura" src\features\timeline\components\*.tsx >nul
if %errorlevel%==0 (
    echo ✅ Imports composants AURA corrects
) else (
    echo ❌ Imports composants AURA incorrects
)

echo.
echo ========================================
echo VERIFICATION DES CHEMINS TERMINEE
echo ========================================
echo.
echo Si tous les chemins sont corrects, le systeme devrait fonctionner.
echo.
pause

