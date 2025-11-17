# Configuration EmailJS pour Booking

## Variables d'environnement requises

Créez un fichier `.env.local` avec :

```bash
# EmailJS Configuration
VITE_EMAILJS_PUBLIC_KEY=pk_xxxxx
VITE_EMAILJS_SERVICE_ID=service_xxxxx
VITE_EMAILJS_TEMPLATE_ID=template_xxxxx
```

## Étapes de configuration

1. **Créer un compte EmailJS**
   - Allez sur https://www.emailjs.com/
   - Créez un compte gratuit

2. **Configurer un service email**
   - Dans le dashboard, allez dans "Email Services"
   - Ajoutez Gmail, Outlook, ou votre fournisseur email
   - Suivez les instructions d'authentification

3. **Créer un template**
   - Allez dans "Email Templates"
   - Créez un nouveau template
   - Utilisez ce contenu HTML :

```html
<h2>Offre artiste - {{artist_name}}</h2>
<p>Bonjour,</p>
<p>Veuillez trouver ci-joint l'offre pour {{artist_name}}.</p>
<p>{{custom_message}}</p>
<p>Valable jusqu'au: {{validity_date}}</p>
<p><a href="{{pdf_url}}" target="_blank">Télécharger l'offre PDF</a></p>
<p>Cordialement,<br>{{from_name}}</p>
```

4. **Variables du template requises**
   - `to_email` : Email destinataire
   - `cc` : Emails en copie (séparés par virgule)
   - `subject` : Sujet de l'email
   - `html_content` : Contenu HTML
   - `pdf_url` : Lien vers le PDF
   - `pdf_filename` : Nom du fichier PDF
   - `artist_name` : Nom de l'artiste
   - `event_name` : Nom de l'événement
   - `validity_date` : Date de validité
   - `custom_message` : Message personnalisé
   - `from_name` : Nom de l'expéditeur
   - `from_email` : Email de l'expéditeur

5. **Copier les clés**
   - Public Key : dans "Account" > "General"
   - Service ID : dans "Email Services"
   - Template ID : dans "Email Templates"

## Test

1. Redémarrez le serveur de développement
2. Allez sur `/app/booking`
3. Cliquez sur "Envoyer" sur une offre
4. Remplissez le formulaire et testez l'envoi

