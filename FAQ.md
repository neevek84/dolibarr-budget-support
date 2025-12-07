# ❓ FAQ - Module Budget pour Dolibarr

## Questions générales

### Quelles versions de Dolibarr sont supportées ?

Le module Budget v1.1.0 est compatible avec :
- **Dolibarr** : version 19.0 et supérieures
- **PHP** : version 7.1 et supérieures

Dolibarr 22.0.3 est donc pleinement compatible.

### Comment mettre à jour le module ?

1. Téléchargez la dernière version depuis [Dolistore](https://www.dolistore.com/product.php?id=2607)
2. Allez dans `Accueil → Configuration → Modules/Applications`
3. Cliquez sur "Déployer un module externe"
4. Sélectionnez le fichier .zip téléchargé
5. Une fois installé, **désactivez puis réactivez le module** pour appliquer les mises à jour de base de données

### Où trouver la version du module installée ?

1. Allez dans `Accueil → Configuration → Modules/Applications`
2. Trouvez "Budget" dans la liste
3. La version est affichée à côté du nom du module

## Problèmes d'installation

### Le module ne s'installe pas

**Vérifications** :
- ✅ Votre version de Dolibarr est-elle ≥ 19.0 ?
- ✅ Votre version PHP est-elle ≥ 7.1 ?
- ✅ Avez-vous les droits d'administration sur Dolibarr ?
- ✅ Le fichier .zip est-il corrompu ? (retéléchargez-le)

### Le module est installé mais n'apparaît pas dans le menu

**Solutions** :
1. Videz le cache : `Accueil → Outils → Purger les caches`
2. Déconnectez-vous et reconnectez-vous
3. Vérifiez que le module est activé (icône verte dans la liste des modules)
4. Vérifiez vos permissions utilisateur

## Problèmes de base de données

### Erreur "Unknown column" lors de l'ajout d'une ligne budgétaire

Voir le [guide de dépannage complet](TROUBLESHOOTING.md#-erreur--unknown-column-fk_budget_main-in-insert-into)

**Solution rapide** : Désactivez puis réactivez le module pour forcer la mise à jour de la base de données.

### Erreur "Table doesn't exist"

**Cause** : Les tables du module n'ont pas été créées lors de l'activation.

**Solution** :
1. Désactivez le module
2. Réactivez le module (cela devrait créer les tables)
3. Si l'erreur persiste, vérifiez les permissions de votre utilisateur MySQL/MariaDB

### Comment sauvegarder mes budgets ?

**Méthode 1 : Sauvegarde de la base de données**
```bash
# ATTENTION: N'incluez jamais de mot de passe dans la ligne de commande
# Utilisez -p sans valeur pour saisir le mot de passe de façon sécurisée
mysqldump -u [utilisateur] -p [nom_base] llx_budget* > backup_budgets.sql
# Le système vous demandera le mot de passe de façon sécurisée
```

**Méthode 2 : Export depuis Dolibarr**
1. Certaines fonctions d'export peuvent être disponibles dans le module
2. Sinon, utilisez la sauvegarde complète de Dolibarr : `Outils → Base de données → Sauvegarde`

## Utilisation du module

### Comment créer un nouveau budget ?

1. Allez dans le menu "Budget"
2. Cliquez sur "Nouveau budget"
3. Remplissez les informations requises :
   - Année fiscale
   - Libellé
   - Type (Budget ou Baseline)
4. Cliquez sur "Créer"
5. Ajoutez des lignes budgétaires

### Quelle est la différence entre Budget et Baseline ?

- **Budget** : Budget prévisionnel initial pour l'année
- **Baseline** : Budget de référence/cible utilisé pour les comparaisons
- **Forecast** : Prévisions actualisées mois par mois
- Le module permet de comparer ces trois valeurs avec le réel

### Comment fonctionne le système de snapshots ?

Les snapshots permettent de :
- Conserver l'historique des révisions de forecast
- Comparer l'évolution des prévisions dans le temps
- Un cronjob automatique peut créer des snapshots mensuels

Pour activer le cronjob :
1. Allez dans `Outils → Tâches planifiées (cron)`
2. Activez la tâche de snapshot des budgets

### Comment cloner un budget existant ?

1. Ouvrez le budget à cloner
2. Utilisez la fonction "Clone budget"
3. Choisissez la nouvelle année fiscale
4. Le module copie toutes les lignes budgétaires

## Performance et limites

### Combien de lignes budgétaires puis-je créer ?

Il n'y a pas de limite stricte imposée par le module. Les limites dépendent de :
- Votre configuration serveur (PHP, MySQL)
- La mémoire disponible
- La performance souhaitée

**Recommandations** :
- Jusqu'à 1000 lignes : Performance optimale
- 1000-5000 lignes : Bon, mais peut ralentir sur petit serveur
- Plus de 5000 lignes : Envisagez une optimisation serveur

### Le module est lent avec beaucoup de données

**Optimisations possibles** :
1. Augmentez les limites PHP (`memory_limit`, `max_execution_time`)
2. Optimisez votre base de données (ajoutez des index si nécessaire)
3. Utilisez un serveur plus performant
4. Activez le cache Dolibarr

## Support et contact

### Comment obtenir de l'aide ?

1. **Consultez d'abord** :
   - Ce FAQ
   - Le [guide de dépannage](TROUBLESHOOTING.md)
   - Les [issues existantes](https://github.com/neevek84/dolibarr-budget-support/issues)

2. **Créez une nouvelle issue** :
   - [Ouvrir une issue](https://github.com/neevek84/dolibarr-budget-support/issues/new)
   - Incluez toutes les informations demandées

3. **Contact direct** :
   - Email : contact@kreativpm.fr
   - Précisez votre numéro de licence/commande Dolistore

### Le module est-il gratuit ?

Non, le module est payant et disponible sur [Dolistore](https://www.dolistore.com/product.php?id=2607).
L'achat inclut :
- Le module complet
- Les mises à jour pendant 1 an
- Le support technique

### Puis-je obtenir le code source ?

Le code source n'est pas disponible publiquement. Ce dépôt GitHub est réservé au support utilisateur et au suivi des bugs.

### Comment proposer une nouvelle fonctionnalité ?

1. Vérifiez qu'elle n'existe pas déjà
2. [Créez une issue](https://github.com/neevek84/dolibarr-budget-support/issues/new) avec le label `enhancement`
3. Décrivez clairement :
   - Le besoin métier
   - La fonctionnalité souhaitée
   - Des exemples d'utilisation

## Mises à jour

### Historique des versions

#### v1.1.0
- ✨ Nouvelles fonctionnalités ajoutées
- 🐛 Corrections de bugs
- Compatible Dolibarr ≥ 19.0

#### v1.0.1
- 🐛 Corrections de bugs mineurs
- Compatible Dolibarr ≥ 19.0

#### v1.0.0
- 🎉 Version initiale
- Compatible Dolibarr ≥ 19.0

### Comment être notifié des mises à jour ?

1. Surveillez votre compte Dolistore pour les notifications
2. Suivez ce dépôt GitHub (bouton "Watch")
3. Inscrivez-vous à la newsletter de KREATIV PROJECT MANAGEMENT

---

**Vous n'avez pas trouvé de réponse ?**  
👉 [Ouvrez une issue](https://github.com/neevek84/dolibarr-budget-support/issues/new)
