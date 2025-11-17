@echo off
echo Diagnostic du problème d'import Toast...
echo.

echo ================================================
echo PROBLÈME IDENTIFIÉ
echo ================================================
echo.
echo ❌ Erreur: "does not provide an export named 'Toast'"
echo 📁 Fichier: ToastProvider.tsx ligne 2
echo 🔍 Import: import ToastComponent, { Toast, ToastType } from "./Toast";
echo.
echo ================================================
echo VÉRIFICATIONS EFFECTUÉES
echo ================================================
echo.
echo ✅ Toast.tsx exports:
echo    - export interface Toast
echo    - export type ToastType  
echo    - export default ToastComponent
echo.
echo ✅ ToastProvider.tsx imports:
echo    - ToastComponent (default export)
echo    - Toast (interface)
echo    - ToastType (type)
echo.
echo ================================================
echo SOLUTIONS POSSIBLES
echo ================================================
echo.

echo 1. REDÉMARRAGE DU SERVEUR:
echo    - Arrêt des processus Node.js
echo    - Redémarrage avec npm run dev
echo    - Nettoyage du cache Vite
echo.

echo 2. VÉRIFICATION DES IMPORTS:
echo    - Ordre des imports correct
echo    - Chemins relatifs corrects
echo    - Exports bien définis
echo.

echo 3. CACHE VITE:
echo    - Suppression de node_modules/.vite
echo    - Redémarrage propre
echo.

echo ================================================
echo TEST À EFFECTUER
echo ================================================
echo.

echo 1. Attendre le redémarrage du serveur
echo.
echo 2. Ouvrir http://localhost:5178/app/booking
echo.
echo 3. Vérifier dans la console:
echo    ✅ Plus d'erreur d'import Toast
echo    ✅ Page se charge correctement
echo.
echo 4. Si l'erreur persiste:
echo    - Vérifier les chemins d'import
echo    - Vérifier les exports dans Toast.tsx
echo    - Nettoyer le cache Vite
echo.

echo ================================================
echo RÉSULTAT ATTENDU
echo ================================================
echo.
echo Le serveur devrait maintenant démarrer sans erreur
echo et les toasts AURA devraient fonctionner !
echo.
pause

