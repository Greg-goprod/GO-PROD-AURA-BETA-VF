@echo off
echo ================================================
echo DIAGNOSTIC - Bouton "Créer un évènement"
echo ================================================
echo.

echo 🔍 PROBLÈME IDENTIFIÉ:
echo    Le company_id n'était pas récupéré correctement
echo.

echo ✅ CORRECTION APPLIQUÉE:
echo    1. Import de getCurrentCompanyId depuis @/lib/tenant
echo    2. Import de supabase depuis @/lib/supabaseClient
echo    3. Ajout d'un state currentCompanyId
echo    4. useEffect pour récupérer le company_id au montage
echo    5. Affichage d'un spinner pendant le chargement
echo.

echo 📋 VÉRIFICATIONS À EFFECTUER:
echo.

echo 1. Ouvrir la console navigateur (F12)
echo    - Vérifier le message: "✅ Company ID récupéré: [uuid]"
echo.

echo 2. Aller sur http://localhost:5180/app/settings/events
echo    - Vérifier qu'un spinner apparaît brièvement
echo    - Vérifier que le bouton "Ajouter un évènement" est visible
echo.

echo 3. Cliquer sur "Ajouter un évènement"
echo    - Le modal EventForm doit s'ouvrir
echo    - Il doit être draggable
echo    - 3 onglets: Informations générales, Jours, Scènes
echo.

echo 4. Dans la console, vérifier:
echo    - Aucune erreur "company_id requis"
echo    - Aucune erreur "companyId manquant"
echo.

echo 5. Remplir le formulaire et enregistrer
echo    - Toast de succès
echo    - Modal se ferme
echo    - Liste des évènements se recharge
echo.

echo ================================================
echo FICHIERS MODIFIÉS
echo ================================================
echo.

echo ✅ src/pages/settings/SettingsEventsPage.tsx
echo    - Import getCurrentCompanyId + supabase
echo    - State currentCompanyId avec useState
echo    - useEffect pour récupérer company_id
echo    - Spinner si company_id non chargé
echo.

echo ================================================
echo COMMANDES
echo ================================================
echo.

echo npm run dev                 : Démarrer le serveur
echo http://localhost:5180/app  : Ouvrir l'app
echo F12                          : Ouvrir la console navigateur
echo.

echo ================================================
echo LOGS ATTENDUS (Console navigateur)
echo ================================================
echo.

echo 🏢 Récupération du company_id...
echo 🔧 Mode développement : Utilisation de l'entreprise de développement
echo 🏢 Mode développement: utilisation de l'entreprise existante Go-Prod HQ
echo ✅ Entreprise Go-Prod HQ trouvée: [uuid] - Go-Prod HQ
echo ✅ Company ID récupéré: [uuid]
echo.

echo ================================================
echo TESTS
echo ================================================
echo.

echo Test 1: Récupération du company_id
echo [ ] Console affiche "✅ Company ID récupéré"
echo [ ] Pas d'erreur "company_id requis"
echo.

echo Test 2: Affichage du bouton
echo [ ] Bouton "Ajouter un évènement" visible
echo [ ] Bouton cliquable
echo.

echo Test 3: Ouverture du modal
echo [ ] Click sur le bouton ouvre le modal
echo [ ] Modal est draggable
echo [ ] 3 onglets visibles
echo.

echo Test 4: Création d'évènement
echo [ ] Remplir le formulaire
echo [ ] Click "Enregistrer"
echo [ ] Toast de succès
echo [ ] Modal se ferme
echo [ ] Liste se recharge
echo.

echo ================================================
echo SI LE PROBLÈME PERSISTE
echo ================================================
echo.

echo 1. Vérifier que la table "companies" contient:
echo    - UUID: 06f6c960-3f90-41cb-b0d7-46937eaf90a8
echo    - Name: Go-Prod HQ
echo.

echo 2. Vérifier la console pour des erreurs Supabase
echo.

echo 3. Vérifier que getCurrentCompanyId retourne bien un UUID
echo.

echo 4. Tester avec le localStorage:
echo    console.log(localStorage.getItem('company_id'))
echo.

echo ================================================
echo PRÊT À TESTER !
echo ================================================
echo.

pause


