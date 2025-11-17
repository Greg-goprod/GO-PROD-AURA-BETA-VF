# 🚨 Installation manuelle des dépendances requises

## Problème
Les dépendances `pdf-lib` et `emailjs-com` n'ont pas pu être installées automatiquement.

## Solution immédiate
Exécutez cette commande dans votre terminal :

```bash
npm install pdf-lib emailjs-com
```

## Alternative PowerShell
Si npm ne fonctionne pas, essayez :

```powershell
# Ouvrir PowerShell en tant qu'administrateur
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
npm install pdf-lib emailjs-com
```

## Alternative CMD
```cmd
# Ouvrir CMD en tant qu'administrateur
npm install pdf-lib emailjs-com
```

## Vérification
Après installation, vérifiez que les packages sont dans `node_modules` :
- `node_modules/pdf-lib/`
- `node_modules/emailjs-com/`

## Après installation
1. **Redémarrez le serveur de développement** :
   ```bash
   npm run dev
   ```

2. **Remplacez les versions temporaires** :
   - `src/features/booking/pdf/pdfFill.ts` → Version avec pdf-lib
   - `src/services/emailService.ts` → Version avec emailjs-com

## Versions temporaires actuelles
- **PDF** : Génère des fichiers HTML au lieu de PDF
- **Email** : Simule l'envoi dans la console

## Fonctionnalités disponibles
✅ **Mode démo** : Fonctionne sans dépendances  
✅ **Modaux AURA** : Tous fonctionnels  
✅ **Kanban** : Drag & drop opérationnel  
✅ **Gestion d'offres** : CRUD complet  
⚠️ **PDF** : Version HTML temporaire  
⚠️ **Email** : Simulation console  

## Test
1. Allez sur `http://localhost:5174/app/booking`
2. Le mode démo s'active automatiquement
3. Tous les boutons fonctionnent
4. Les modaux s'ouvrent correctement
5. Consultez la console pour voir les simulations

