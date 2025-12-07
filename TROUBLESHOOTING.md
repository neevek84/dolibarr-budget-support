# 🔧 Guide de dépannage - Module Budget

## ❌ Erreur : "Unknown column 'fk_budget_main' in 'INSERT INTO'"

### 📋 Description du problème

Cette erreur se produit lors de l'ajout d'une ligne budgétaire et indique que la structure de la base de données n'est pas à jour avec la version du module installée.

### 🔍 Causes possibles

1. **Mise à jour incomplète du module** - La base de données n'a pas été mise à jour après l'installation/mise à jour du module
2. **Version incompatible** - Le module installé n'est pas compatible avec votre version de Dolibarr
3. **Migration de base de données non exécutée** - Les scripts de migration SQL n'ont pas été exécutés

### ✅ Solutions

#### Solution 1 : Forcer la mise à jour de la base de données

1. **Connectez-vous à Dolibarr en tant qu'administrateur**
2. **Accédez à** : `Accueil → Configuration → Modules/Applications`
3. **Désactivez le module Budget** (cliquez sur l'icône OFF)
4. **Réactivez le module Budget** (cliquez sur l'icône ON)
   - Cette opération force l'exécution des scripts de mise à jour de la base de données
5. **Vérifiez** que l'erreur ne se reproduit plus

#### Solution 2 : Vérifier la version du module

1. **Vérifiez votre version actuelle** :
   - Allez dans `Accueil → Configuration → Modules/Applications`
   - Trouvez le module "Budget"
   - Notez la version affichée

2. **Vérifiez la compatibilité** :
   - Module v1.1.0 : Compatible avec Dolibarr ≥ 19.0
   - Dolibarr 22.0.3 devrait être compatible

3. **Mettez à jour si nécessaire** :
   - Téléchargez la dernière version depuis [Dolistore](https://www.dolistore.com/product.php?id=2607)
   - Installez la mise à jour via `Accueil → Configuration → Modules/Applications → Déployer un module externe`

#### Solution 3 : Migration manuelle de la base de données (Avancé)

⚠️ **IMPORTANT** : Effectuez une sauvegarde complète de votre base de données avant toute manipulation SQL !

Si les solutions précédentes ne fonctionnent pas, la colonne manquante doit être ajoutée manuellement :

1. **Sauvegardez votre base de données**
   ```bash
   # ATTENTION: N'incluez jamais de mot de passe dans la ligne de commande
   # Utilisez --defaults-extra-file ou laissez -p sans valeur pour saisir le mot de passe de façon sécurisée
   mysqldump -u [utilisateur] -p [nom_base] > backup_$(date +%Y%m%d).sql
   # Le système vous demandera le mot de passe de façon sécurisée
   ```

2. **Identifiez la table concernée**
   - L'erreur concerne probablement la table `llx_budget_lines` ou similaire

3. **Contactez le support** avant de modifier manuellement la base de données :
   - Ouvrez une [issue sur GitHub](https://github.com/neevek84/dolibarr-budget-support/issues)
   - Incluez :
     - Version exacte du module Budget (visible dans la liste des modules)
     - Version de Dolibarr
     - Copie du message d'erreur complet
     - Historique des mises à jour effectuées

#### Solution 4 : Réinstallation propre du module

Si aucune solution ne fonctionne :

1. **Sauvegardez vos données** (exportez vos budgets si possible)
2. **Désinstallez complètement le module** :
   - Désactivez le module
   - Supprimez les fichiers du module du serveur (dossier `htdocs/custom/budget` ou similaire)
3. **Nettoyez la base de données** (optionnel, conserve les données) :
   - Les tables du module commencent généralement par `llx_budget_`
4. **Réinstallez la dernière version** depuis Dolistore
5. **Activez le module** - cela créera les tables avec la bonne structure

### 📊 Informations à fournir pour le support

Si vous avez besoin d'aide, créez une [nouvelle issue](https://github.com/neevek84/dolibarr-budget-support/issues/new) avec :

- ✅ **Version de Dolibarr** : (ex: 22.0.3)
- ✅ **Version du module Budget** : (visible dans Configuration → Modules)
- ✅ **Message d'erreur complet** : (copier/coller depuis les logs)
- ✅ **Étapes effectuées** : (quelles solutions avez-vous essayées)
- ✅ **Environnement** : 
  - Version PHP
  - Version MySQL/MariaDB
  - Hébergement (local, mutualisé, VPS, etc.)

### 🔗 Liens utiles

- [Documentation Dolibarr](https://wiki.dolibarr.org)
- [Forum Dolibarr](https://dolibarr.org/forum)
- [Dolistore - Module Budget](https://www.dolistore.com/product.php?id=2607)

---

## 📝 Autres problèmes courants

### Erreur : "Table 'llx_budget_lines' doesn't exist"

**Solution** : Même procédure que ci-dessus - désactiver/réactiver le module pour créer les tables manquantes.

### Le module ne s'affiche pas dans le menu

**Solution** : 
1. Vérifiez que le module est bien activé
2. Videz le cache Dolibarr : `Accueil → Outils → Purger les caches`
3. Vérifiez les permissions utilisateur

### Erreur de permissions sur les budgets

**Solution** :
1. Allez dans `Configuration → Utilisateurs & Groupes`
2. Éditez l'utilisateur concerné
3. Vérifiez les permissions dans l'onglet "Permissions"
4. Assurez-vous que les permissions du module Budget sont cochées
