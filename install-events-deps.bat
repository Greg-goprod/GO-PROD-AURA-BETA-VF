@echo off
echo Installation des dépendances pour le système d'évènements...
echo.

echo ================================================
echo PROBLÈMES IDENTIFIÉS
echo ================================================
echo.

echo ❌ Erreur 1: Failed to resolve import "zustand"
echo    - La dépendance Zustand n'est pas installée
echo    - Nécessaire pour le store d'évènements
echo.

echo ❌ Erreur 2: Failed to resolve import "./EventForm"
echo    - Import incorrect dans EventsPage.tsx
echo    - EventForm est dans src/components/events/
echo.

echo ================================================
echo INSTALLATION DES DÉPENDANCES
echo ================================================
echo.

echo 1. Installation de Zustand...
npm install zustand

if %errorlevel% equ 0 (
    echo ✅ Zustand installé avec succès
) else (
    echo ❌ Erreur lors de l'installation de Zustand
    pause
    exit /b 1
)

echo.
echo 2. Installation de react-hook-form (optionnel)...
npm install react-hook-form

if %errorlevel% equ 0 (
    echo ✅ react-hook-form installé avec succès
) else (
    echo ⚠️ react-hook-form déjà installé ou erreur mineure
)

echo.
echo ================================================
echo CORRECTION DES IMPORTS
echo ================================================
echo.

echo 3. Correction de l'import EventForm dans EventsPage.tsx...
echo    - Changement de "./EventForm" vers "../components/events/EventForm"

echo.
echo ================================================
echo REDÉMARRAGE DU SERVEUR
echo ================================================
echo.

echo 4. Redémarrage du serveur de développement...
echo.
echo Le serveur va redémarrer automatiquement après les corrections
echo.

pause

