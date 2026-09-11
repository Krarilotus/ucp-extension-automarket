# Automarket

Cette extension fournit un marché automatique.

## Fonctions

L’interface est intégrée directement au jeu.

![Automarket](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/ui-automarket-button.png)

Fonctionne en multijoueur si tous les participants activent l’extension.

La version 1.1.0 corrige un débordement du paquet de réglages multijoueur et le calcul des frais de commerce. Tous les joueurs doivent mettre à jour ensemble. Les frais de chaque joueur sont synchronisés avec **Save & Close**. Utilisez les mêmes frais configurés si chacun doit payer le même taux. Après le chargement d’une sauvegarde 1.0.0, chaque joueur doit confirmer ses réglages existants avec **Save & Close** avant la reprise du commerce automatique.

## Dépannage et problèmes connus

Un problème de stabilité peut faire planter le jeu aléatoirement après le chargement ou plus tard. Une option de l’onglet Personnalisations peut éviter ce plantage si elle en traite la cause : **Désactiver la compilation à la volée de LuaJIT, au détriment des performances**. Cochez-la pour éviter cette cause de plantage.

![LuaJIT](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/stability-debugging-setting.png)

Si le jeu plante encore, merci de le signaler.

## Fonctionnement

Un bouton supplémentaire dans le marché ouvre un menu présentant toutes les marchandises, leurs stocks et les réglages du marché automatique.

Chaque semaine de jeu, le marché vend puis achète, dans cet ordre. Cliquez sur une marchandise et ajustez les curseurs. Validez ensuite les réglages avec l’icône de coche.

Le seuil d’achat doit toujours être inférieur au seuil de vente. Sinon, vous risquez de dépenser tout votre or en vendant puis en rachetant immédiatement. Le code comporte des protections contre cette situation.
