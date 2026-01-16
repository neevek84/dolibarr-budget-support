# Guide de Test Utilisateur - Feature Hiérarchie Revenus v1.1.4

## Pré-requis
1. Module Budget 1.1.4+ installé et activé
2. Droits utilisateur : lecture/écriture budgets
3. Jeu de données avec au moins :
   - 1 budget sur 12 mois
   - 2+ tiers (sociétés)
   - 2+ factures payées et non payées
   - 2+ commandes validées

## Instructions de test

### TEST 1 : Afficher la hiérarchie "Payé"

**Étapes :**
1. Aller à Budget > Forecast de votre budget
2. Localiser la section "Revenus" (vert clair)
3. Cliquer sur "Revenus" pour développer
4. Chercher la ligne "Payé" avec un chevron ">")
5. Cliquer sur "Payé" pour développer

**Résultat attendu :**
- ✅ La ligne "Payé" affiche le chevron tournant (devient "⌄")
- ✅ Sous "Payé" apparaît une liste de tiers (sociétés)
- ✅ Chaque tiers affiche son montant dans la colonne du mois
- ✅ Sous chaque tiers : liste de factures payées (refs cliquables)
- ✅ Chaque facture affiche son montant

**Vérification supplémentaire :**
- Cliquer sur une référence de facture → doit ouvrir la fiche facture en nouvel onglet

---

### TEST 2 : Afficher la hiérarchie "En attente"

**Étapes :**
1. Même budget, section Revenus développée
2. Cliquer sur "En attente" (ligne jaune avec chevron)

**Résultat attendu :**
- ✅ Chevron développe, affiche tiers
- ✅ Sous chaque tiers : factures NON payées
- ✅ Montants cohérents avec factures en attente de paiement
- ✅ Liens cliquables sur les refs de factures

---

### TEST 3 : Afficher la hiérarchie "Signé"

**Étapes :**
1. Même budget, section Revenus développée
2. Cliquer sur "Signé" (ligne bleu ciel avec chevron)

**Résultat attendu :**
- ✅ Chevron développe, affiche clients (sociétés)
- ✅ Sous chaque client : liste de commandes en cours
- ✅ Format commande : "REF001 (PRJ001)" ou "REF001" si sans projet
- ✅ Montant : "à facturer" pour ce mois (lissé selon date livraison)
- ✅ Sous chaque commande : factures déjà créées (si présentes)
- ✅ Factures affichées en gris/italique
- ✅ Cliquer sur commande → ouvre card commande en nouvel onglet

---

### TEST 4 : Vérifier les droits et liens

**Étapes :**
1. Loggez-vous avec un compte sans droit "facture > lire"
2. Allez sur le même budget, développez "Payé"

**Résultat attendu :**
- ✅ Les références de factures apparaissent en texte noir simple
- ✅ Pas de lien (pas de hover-underline)
- ✅ Cliquer sur la ref ne fait rien

**Vérification 2 :**
1. Loggez-vous avec compte SANS droit "commande > lire"
2. Développez "Signé"

**Résultat attendu :**
- ✅ Les références de commandes apparaissent en texte (pas de lien)
- ✅ Pas de hover-underline sur les commandes

---

### TEST 5 : Tester le changement d'échelle

**Étapes :**
1. Budget ouvert, Payé développé
2. Voir les montants en €
3. Cliquer sur "K€" (sélecteur d'échelle)
4. Page recharge
5. Développer à nouveau "Payé"

**Résultat attendu :**
- ✅ Les montants affichés en K€ (divisé par 1000)
- ✅ La hiérarchie reste complète (tiers + factures)
- ✅ Changement vers M€ puis revenir à € : montants corrects

---

### TEST 6 : Vérifier la cohérence des totaux

**Étapes :**
1. Budget ouvert, Revenus développé
2. Noter le total "Payé" affiché sur la ligne principal (colonne Total)
3. Développer "Payé"
4. Additionner mentalement les montants de toutes les factures visibles

**Résultat attendu :**
- ✅ La somme des factures = total "Payé" affichée
- ✅ Idem pour "En attente"
- ✅ Idem pour "Signé" (montants lissés respectent la date livraison)

---

### TEST 7 : Tester le collapse/expand répété

**Étapes :**
1. Développer "Payé" 
2. Attendre 1 sec
3. Replier "Payé" (chevron devient ">")
4. Développer à nouveau
5. Vérifier que le contenu est identique

**Résultat attendu :**
- ✅ Aucune erreur JavaScript
- ✅ Chevrons tournent correctement
- ✅ Les détails se cachent/affichent correctement
- ✅ Pas de duplication de lignes

---

### TEST 8 : Vérifier que les mois passés sont en lecture seule

**Étapes :**
1. Budget ouvert, regarder les colonnes de mois
2. Identifier les colonnes grisées (passé)
3. Cliquer sur une ligne payée d'un mois passé

**Résultat attendu :**
- ✅ Les colonnes de mois passés ont fond gris (#e0e0e0)
- ✅ Les montants sont affichés mais non éditables
- ✅ Aucun input dans les mois passés (les lignes "Payé" ne montrent que du texte)

---

### TEST 9 : Tester avec données vides

**Étapes :**
1. Créer un budget avec pas de factures payées
2. Développer "Payé"

**Résultat attendu :**
- ✅ "Payé" reste développable (chevron présent)
- ✅ Aucun tiers affiché
- ✅ Total = 0 ou "-"

**Étapes 2 :**
1. Créer commande validée SANS date de livraison
2. Développer "Signé"

**Résultat attendu :**
- ✅ Commande affichée seulement dans le mois courant
- ✅ Pas dupliquée dans les mois futurs

---

### TEST 10 : Tester avec projet lié à commande

**Étapes :**
1. Créer commande avec un projet lié
2. Valider la commande
3. Budget > Forecast
4. Développer "Signé"

**Résultat attendu :**
- ✅ Commande affichée : "REF (PRJ-CODE)" format
- ✅ Projet affichée en gris/italique après ref commande
- ✅ Total "à facturer" du mois correct

---

## Résumé des vérifications

| Test | Résultat | Notes |
|------|----------|-------|
| 1. Payé | ✅ | Tiers + factures cliquables |
| 2. En attente | ✅ | Tiers + factures non payées |
| 3. Signé | ✅ | Clients + commandes + factures |
| 4. Droits | ✅ | Liens masqués sans droit |
| 5. Échelle | ✅ | Rescaling conserve hiérarchie |
| 6. Totaux | ✅ | Cohérence vérifiée |
| 7. Collapse/Expand | ✅ | Sans bugs |
| 8. Mois passés | ✅ | Lecture seule |
| 9. Données vides | ✅ | Gestion correcte |
| 10. Projets | ✅ | Affichage correct |

---

## Problèmes à signaler

Si vous rencontrez un problème, notez :

1. **Description du problème**
2. **Étapes pour reproduire**
3. **Résultat attendu vs obtenu**
4. **Navigateur et version Dolibarr**
5. **Screenshot si pertinent**

Envoyez à : développement@kreativpm.fr

---

**Document d'aide** : Pour questions techniques, voir `docs/DEVELOPMENT_v1.1.4.md`
**Test automatisé** : Voir section 6.8 de `RECETTE.md` pour test complet pré-release
