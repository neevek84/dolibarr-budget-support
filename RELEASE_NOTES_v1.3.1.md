# Budget Module v1.3.1 — Release Notes

**Compatible Dolibarr 19+** | **PHP 7.1+**

## ✨ Nouveautés v1.3.1

### Paiements divers (Banque > Paiements divers)
- Les **paiements divers au crédit** sont intégrés aux **Revenus**, les **paiements divers au débit** aux **Dépenses**, à leur date de paiement.
- Forecast : bloc « Paiements divers » dédié de chaque côté, regroupé par compte comptable, avec lien vers chaque paiement. Inclus dans les totaux et le solde.
- Inclus dans le réalisé de toutes les vues : comparaison budget/réalisé, impression/PDF, exports CSV/Excel/XML, évolution, suivi YTD.
- Clonage « Reprendre les données réalisées » : une ligne par compte comptable.

## 📦 Rappel des versions 1.2.x – 1.3.0 incluses
- **Charges sociales et fiscales** et **salaires** côté Dépenses (projection + réalisé) — v1.2.0
- Engagé (commandes fournisseurs), factures fournisseurs récurrentes, emprunts, contrats/abonnements — v1.2.0 / v1.2.1
- Clonage de budget à 2 modes, budgets liés à un projet avec partage, filtre Forecast par tiers/fournisseur — v1.2.1 / v1.3.0

## ⬆️ Mise à jour
- Depuis 1.3.0 : remplacer les fichiers du module, aucune migration SQL.
- Depuis une version antérieure à 1.3.0 : remplacer les fichiers puis **désactiver / réactiver** le module pour appliquer les migrations SQL.

Détails : [ChangeLog.md](ChangeLog.md) · [FEATURES.md](FEATURES.md) · [README.md](README.md) · [README_EN.md](README_EN.md)

---

**Licence** : GPL v3+  
**Auteur** : KREATIV PROJECT MANAGEMENT SASU
