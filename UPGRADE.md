# Guide de mise à jour du module Budget

## ⚠️ Note importante

**Si vous installez le module pour la première fois en version 1.1.0, vous n'avez rien à faire.** Les tables seront créées automatiquement avec la bonne structure lors de l'activation du module.

Ce guide concerne uniquement les utilisateurs qui **mettent à jour** depuis une version antérieure (< 1.0.1).

---

## Mise à jour depuis une version < 1.0.1 vers 1.1.0

Si vous rencontrez l'erreur suivante lors de l'ajout d'une ligne de budget :
```
Unknown column 'fk_budget_main' in 'INSERT INTO'
```

Cela signifie que votre structure de base de données n'est pas à jour avec la version 1.1.0 du module.

### Solution 1 : Réinstallation automatique (Recommandé)

La méthode la plus simple et sûre est de désactiver puis réactiver le module :

1. **Sauvegarder vos données** (facultatif mais recommandé) :
   ```bash
   mysqldump -u [user] -p [database] llx_budget_main llx_budget_lines llx_budget_amounts llx_budget_forecast_amounts llx_budget_forecast_snapshot > budget_backup.sql
   ```

2. **Désactiver le module** :
   - Allez dans : Accueil → Configuration → Modules/Applications
   - Recherchez "Budget"
   - Cliquez sur le bouton pour désactiver le module

3. **Réactiver le module** :
   - Cliquez à nouveau sur le bouton pour activer le module
   - Les tables seront automatiquement mises à jour

### Solution 2 : Migration manuelle via SQL

Si vous ne pouvez pas désactiver/réactiver le module (pour conserver certaines données), vous pouvez exécuter manuellement le script de migration :

1. **Connectez-vous à votre base de données** :
   ```bash
   mysql -u [user] -p [database]
   ```

2. **Exécutez le script de migration** :
   ```bash
   mysql -u [user] -p [database] < /htdocs/custom/budget/sql/upgrade_to_1.1.0.sql
   ```

   Ou depuis l'interface phpMyAdmin :
   - Ouvrez phpMyAdmin
   - Sélectionnez votre base de données Dolibarr
   - Allez dans l'onglet "SQL"
   - Copiez/collez le contenu du fichier `sql/upgrade_to_1.1.0.sql`
   - Cliquez sur "Exécuter"

3. **Vérifiez que la migration s'est bien déroulée** :
   ```sql
   SHOW COLUMNS FROM llx_budget_lines LIKE 'fk_budget_main';
   ```
   
   Vous devriez voir la colonne `fk_budget_main` dans les résultats.

### Solution 3 : Création manuelle de la colonne (Expert)

Si vous préférez ajouter manuellement la colonne sans exécuter le script complet :

```sql
-- Ajouter la colonne fk_budget_main
ALTER TABLE llx_budget_lines 
ADD COLUMN fk_budget_main INTEGER NOT NULL AFTER entity;

-- Ajouter la contrainte de clé étrangère
ALTER TABLE llx_budget_lines 
ADD CONSTRAINT fk_budget_lines_budget_main 
FOREIGN KEY (fk_budget_main) REFERENCES llx_budget_main(rowid);
```

## Mise à jour depuis 1.0.1 vers 1.1.0

Si vous avez déjà la version 1.0.1, aucune modification de base de données n'est nécessaire. Copiez simplement les nouveaux fichiers du module.

## Vérification de la version installée

Pour vérifier la version actuelle du module :
1. Allez dans : Accueil → Configuration → Modules/Applications
2. Recherchez "Budget"
3. La version apparaît à côté du nom du module

## En cas de problème

Si vous rencontrez toujours des erreurs après la mise à jour :

1. **Vérifiez les logs Dolibarr** : `documents/dolibarr.log`
2. **Vérifiez les logs MySQL** : Recherchez les erreurs SQL
3. **Contactez le support** : https://github.com/neevek84/dolibarr-budget-support/issues

## Notes importantes

- ⚠️ **Sauvegardez toujours votre base de données avant une mise à jour**
- ⚠️ **Testez la mise à jour sur un environnement de développement d'abord**
- ✅ Le script de migration est **idempotent** : vous pouvez l'exécuter plusieurs fois sans risque
- ✅ Les données existantes sont **préservées** lors de la mise à jour

## Changements de structure de base de données

### Version 1.0.1
- Restructuration complète des tables SQL
- Séparation des fichiers SQL (CREATE TABLE / KEYS / DATA)
- Introduction de la colonne `fk_budget_main` dans `llx_budget_lines`
- Introduction de la colonne `fk_budget_line` dans `llx_budget_amounts` et `llx_budget_forecast_amounts`

### Version 1.1.0
- Aucun changement de structure
- Nouvelles fonctionnalités : clonage, sélecteur d'échelle, affichage des revenus négatifs

---

**Copyright (C) 2025 KREATIV PROJECT MANAGEMENT SASU**  
*Licence GPL v3+ - GNU General Public License version 3 ou ultérieure*
