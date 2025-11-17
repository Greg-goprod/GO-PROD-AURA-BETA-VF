# Configuration EmailJS - Exemple

## Variables d'environnement requises

Créez un fichier `.env.local` dans la racine du projet :

```bash
# EmailJS Configuration
VITE_EMAILJS_PUBLIC_KEY=pk_xxxxx
VITE_EMAILJS_SERVICE_ID=service_xxxxx
VITE_EMAILJS_TEMPLATE_ID=template_xxxxx
```

## Étapes de configuration EmailJS

### 1. Créer un compte EmailJS
- Allez sur https://www.emailjs.com/
- Créez un compte gratuit
- Confirmez votre email

### 2. Configurer un service email
- Dans le dashboard, allez dans "Email Services"
- Cliquez "Add New Service"
- Choisissez votre fournisseur (Gmail, Outlook, etc.)
- Suivez les instructions d'authentification
- Notez le **Service ID** (ex: `service_abc123`)

### 3. Créer un template email
- Allez dans "Email Templates"
- Cliquez "Create New Template"
- Utilisez ce contenu HTML :

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Offre Artiste</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5;">
    <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        
        <h1 style="color: #333; border-bottom: 2px solid #666; padding-bottom: 10px;">{{subject}}</h1>
        
        <p>Bonjour {{to_name}},</p>
        
        <p>Veuillez trouver ci-joint l'offre pour <strong>{{artist_name}}</strong>.</p>
        
        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h3 style="margin-top: 0; color: #333;">Détails de l'offre</h3>
            <p><strong>Artiste:</strong> {{artist_name}}</p>
            <p><strong>Événement:</strong> {{event_name}}</p>
            <p><strong>Validité:</strong> {{validity_date}}</p>
        </div>
        
        {{#custom_message}}
        <div style="background-color: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h4 style="margin-top: 0; color: #1976d2;">Message personnalisé</h4>
            <p>{{custom_message}}</p>
        </div>
        {{/custom_message}}
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="{{pdf_url}}" 
               style="display: inline-block; background-color: #1976d2; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                📄 Télécharger l'offre PDF
            </a>
        </div>
        
        <p>Cordialement,<br>
        <strong>{{from_name}}</strong><br>
        {{from_email}}</p>
        
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="font-size: 12px; color: #666; text-align: center;">
            Cet email a été généré automatiquement par Go-Prod
        </p>
    </div>
</body>
</html>
```

### 4. Variables du template
Assurez-vous que votre template contient ces variables :
- `{{to_email}}` - Email destinataire
- `{{to_name}}` - Nom du destinataire
- `{{cc}}` - Emails en copie
- `{{subject}}` - Sujet de l'email
- `{{from_name}}` - Nom de l'expéditeur
- `{{from_email}}` - Email de l'expéditeur
- `{{artist_name}}` - Nom de l'artiste
- `{{event_name}}` - Nom de l'événement
- `{{validity_date}}` - Date de validité
- `{{custom_message}}` - Message personnalisé
- `{{pdf_url}}` - Lien vers le PDF
- `{{pdf_filename}}` - Nom du fichier PDF

### 5. Récupérer les clés
- **Public Key** : Dans "Account" > "General" > "Public Key"
- **Service ID** : Dans "Email Services" > votre service
- **Template ID** : Dans "Email Templates" > votre template

### 6. Test
1. Redémarrez le serveur : `npm run dev`
2. Allez sur `/app/booking`
3. Créez une offre et testez l'envoi
4. Vérifiez que l'email arrive avec le lien PDF

## Dépannage

### Email ne s'envoie pas
- Vérifiez que les 3 variables d'environnement sont définies
- Vérifiez que le template contient toutes les variables requises
- Consultez la console pour les erreurs

### PDF ne s'ouvre pas
- Vérifiez que le bucket `offers` existe dans Supabase
- Vérifiez les permissions RLS du bucket
- L'URL signée expire après 7 jours

### Mode démo
Si EmailJS n'est pas configuré, l'application fonctionne en mode démo :
- Les emails sont simulés dans la console
- Les PDFs sont générés mais pas envoyés
- Toutes les autres fonctionnalités marchent normalement

