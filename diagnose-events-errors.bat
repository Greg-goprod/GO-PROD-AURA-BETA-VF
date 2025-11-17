@echo off
echo Diagnostic du système d'évènements...
echo.

echo ================================================
echo ERREURS DÉTECTÉES
echo ================================================
echo.

echo ❌ ERREUR 1: Failed to resolve import "zustand"
echo    📁 Fichier: src/store/useEventStore.ts:1
echo    🔍 Cause: Dépendance Zustand non installée
echo    ✅ Solution: npm install zustand
echo.

echo ❌ ERREUR 2: Failed to resolve import "./EventForm"
echo    📁 Fichier: src/pages/administration/EventsPage.tsx:12
echo    🔍 Cause: Import incorrect (chemin relatif)
echo    ✅ Solution: Corrigé vers "../../components/events/EventForm"
echo.

echo ================================================
echo CORRECTIONS APPLIQUÉES
echo ================================================
echo.

echo ✅ Import EventForm corrigé dans EventsPage.tsx
echo ✅ Script d'installation créé (install-deps-simple.bat)
echo.

echo ================================================
echo ACTIONS REQUISES
echo ================================================
echo.

echo 1. INSTALLER ZUSTAND:
echo    - Exécuter: install-deps-simple.bat
echo    - Ou manuellement: npm install zustand
echo.

echo 2. REDÉMARRER LE SERVEUR:
echo    - Arrêter le serveur (Ctrl+C)
echo    - Relancer: npm run dev
echo.

echo 3. VÉRIFIER LE FONCTIONNEMENT:
echo    - Ouvrir http://localhost:5179/app
echo    - Vérifier que l'EventSelector apparaît dans le header
echo    - Tester la création d'un évènement
echo.

echo ================================================
echo RÉSULTAT ATTENDU
echo ================================================
echo.

echo 🎉 Après installation de Zustand:
echo    - Plus d'erreur "Failed to resolve import zustand"
echo    - Plus d'erreur "Failed to resolve import EventForm"
echo    - EventSelector visible dans le header
echo    - Système d'évènements fonctionnel
echo.

echo ================================================
echo COMMANDES À EXÉCUTER
echo ================================================
echo.

echo 1. npm install zustand
echo 2. npm install react-hook-form
echo 3. npm run dev
echo.

pause

