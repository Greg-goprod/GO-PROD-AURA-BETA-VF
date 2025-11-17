@echo off
echo Remplacement de TimelineGrid par la version simplifiee...
echo.

echo Sauvegarde de la version originale...
if exist "src\features\timeline\components\TimelineGrid.tsx" (
    copy "src\features\timeline\components\TimelineGrid.tsx" "src\features\timeline\components\TimelineGrid_BACKUP.tsx"
    echo ✅ Sauvegarde creee: TimelineGrid_BACKUP.tsx
) else (
    echo ❌ TimelineGrid.tsx non trouve
    pause
    exit /b 1
)

echo.
echo Remplacement par la version simplifiee...
copy "src\features\timeline\components\TimelineGrid_SIMPLE.tsx" "src\features\timeline\components\TimelineGrid.tsx"
echo ✅ Version simplifiee activee

echo.
echo ========================================
echo REMPLACEMENT TERMINE
echo ========================================
echo.
echo La version simplifiee de TimelineGrid est maintenant active.
echo Cette version n'utilise pas @dnd-kit pour eviter les erreurs d'import.
echo.
echo Fonctionnalites disponibles:
echo - Affichage de la grille jours x scenes
echo - Clic sur cellule vide pour creer une performance
echo - Clic sur carte pour editer
echo - Pas de drag & drop (pour l'instant)
echo.
echo Pour restaurer la version originale avec DnD:
echo copy src\features\timeline\components\TimelineGrid_BACKUP.tsx src\features\timeline\components\TimelineGrid.tsx
echo.
echo Testez maintenant: http://localhost:5176/app/lineup/timeline
echo.
pause

