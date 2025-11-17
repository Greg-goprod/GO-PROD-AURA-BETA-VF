@echo off
echo Remplacement temporaire de LineupTimelinePage pour diagnostic...
echo.

echo Sauvegarde de la version originale...
if exist "src\pages\LineupTimelinePage.tsx" (
    copy "src\pages\LineupTimelinePage.tsx" "src\pages\LineupTimelinePage_BACKUP.tsx"
    echo ✅ Sauvegarde creee: LineupTimelinePage_BACKUP.tsx
) else (
    echo ❌ LineupTimelinePage.tsx non trouve
    pause
    exit /b 1
)

echo.
echo Remplacement par la version de test...
copy "src\pages\LineupTimelinePage_TEST.tsx" "src\pages\LineupTimelinePage.tsx"
echo ✅ Version de test activee

echo.
echo ========================================
echo REMPLACEMENT TERMINE
echo ========================================
echo.
echo Maintenant:
echo 1. Rechargez la page http://localhost:5175/app/lineup/timeline
echo 2. Vous devriez voir une page de test simple
echo 3. Si ca fonctionne, le probleme vient des composants complexes
echo 4. Si ca ne fonctionne pas, le probleme vient de la route ou du serveur
echo.
echo Pour restaurer la version originale:
echo copy src\pages\LineupTimelinePage_BACKUP.tsx src\pages\LineupTimelinePage.tsx
echo.
pause

