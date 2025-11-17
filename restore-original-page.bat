@echo off
echo Restauration de la version originale de LineupTimelinePage...
echo.

if exist "src\pages\LineupTimelinePage_BACKUP.tsx" (
    copy "src\pages\LineupTimelinePage_BACKUP.tsx" "src\pages\LineupTimelinePage.tsx"
    echo ✅ Version originale restauree
    
    echo.
    echo Nettoyage des fichiers temporaires...
    del "src\pages\LineupTimelinePage_BACKUP.tsx"
    del "src\pages\LineupTimelinePage_TEST.tsx"
    echo ✅ Fichiers temporaires supprimes
) else (
    echo ❌ Fichier de sauvegarde non trouve
    echo La version originale n'a pas ete sauvegardee
)

echo.
echo ========================================
echo RESTAURATION TERMINEE
echo ========================================
echo.
echo La version originale de LineupTimelinePage est restauree.
echo Rechargez la page pour tester.
echo.
pause

